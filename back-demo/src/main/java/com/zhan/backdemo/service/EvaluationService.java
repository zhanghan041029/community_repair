package com.zhan.backdemo.service;

import com.zhan.backdemo.common.Constants;
import com.zhan.backdemo.common.PageResult;
import com.zhan.backdemo.dto.EvaluationCreateRequest;
import com.zhan.backdemo.dto.EvaluationReplyRequest;
import com.zhan.backdemo.entity.Evaluation;
import com.zhan.backdemo.entity.RepairOrder;
import com.zhan.backdemo.exception.BusinessException;
import com.zhan.backdemo.mapper.EvaluationMapper;
import com.zhan.backdemo.service.NotificationService;
import com.zhan.backdemo.service.RepairService;
import com.zhan.backdemo.vo.EvaluationVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EvaluationService {

    private final EvaluationMapper evaluationMapper;
    private final RepairService repairService;
    private final NotificationService notificationService;

    public void createEvaluation(Long userId, EvaluationCreateRequest request) {
        RepairOrder order = repairService.getRepairOrder(request.getRepairId());
        if (!userId.equals(order.getUserId())) {
            throw new BusinessException("只能评价自己的工单");
        }
        if (!Constants.REPAIR_STATUS_COMPLETED.equals(order.getStatus())) {
            throw new BusinessException("仅已完成的工单可以评价");
        }
        if (evaluationMapper.findByRepairId(request.getRepairId()) != null) {
            throw new BusinessException("该工单已评价");
        }

        Evaluation evaluation = new Evaluation();
        evaluation.setRepairId(request.getRepairId());
        evaluation.setUserId(userId);
        evaluation.setScore(request.getScore());
        evaluation.setComment(request.getComment());
        evaluationMapper.insert(evaluation);
    }

    public EvaluationVO getEvaluationByRepairId(Long repairId, String role, Long userId) {
        RepairOrder order = repairService.getRepairOrder(repairId);
        if (Constants.ROLE_RESIDENT.equals(role) && !userId.equals(order.getUserId())) {
            throw new BusinessException("无权限查看该评价");
        }
        if (Constants.ROLE_WORKER.equals(role) && !userId.equals(order.getWorkerId())) {
            throw new BusinessException("无权限查看该评价");
        }

        EvaluationVO evaluation = evaluationMapper.findVoByRepairId(repairId);
        if (evaluation == null) {
            throw new BusinessException("该工单暂无评价");
        }
        return evaluation;
    }

    public PageResult<EvaluationVO> getMyEvaluations(Long userId, Integer page, Integer pageSize) {
        int currentPage = page == null || page < 1 ? 1 : page;
        int size = pageSize == null || pageSize < 1 ? 10 : pageSize;
        int offset = (currentPage - 1) * size;

        long total = evaluationMapper.countByUserId(userId);
        List<EvaluationVO> rows = evaluationMapper.listByUserId(userId, offset, size);
        return new PageResult<>(total, rows);
    }

    public void replyEvaluation(EvaluationReplyRequest request, Long workerId) {
        Evaluation evaluation = evaluationMapper.findById(request.getEvaluationId());
        if (evaluation == null) {
            throw new BusinessException("评价不存在");
        }
        RepairOrder order = repairService.getRepairOrder(evaluation.getRepairId());
        if (!workerId.equals(order.getWorkerId())) {
            throw new BusinessException("只能回复自己工单的评价");
        }

        Evaluation update = new Evaluation();
        update.setId(evaluation.getId());
        update.setReply(request.getReply());
        update.setReplyTime(LocalDateTime.now());
        evaluationMapper.updateReply(update);

        // 给居民发送通知
        notificationService.sendNotification(
                order.getUserId(),
                "评价回复提醒",
                "维修工已回复您的评价（工单：" + order.getTitle() + "）：" + request.getReply(),
                "evaluation_reply"
        );
    }
}
