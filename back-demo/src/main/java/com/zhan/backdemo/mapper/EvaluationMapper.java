package com.zhan.backdemo.mapper;

import com.zhan.backdemo.entity.Evaluation;
import com.zhan.backdemo.vo.EvaluationVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface EvaluationMapper {

    int insert(Evaluation evaluation);

    Evaluation findByRepairId(@Param("repairId") Long repairId);

    EvaluationVO findVoByRepairId(@Param("repairId") Long repairId);

    long countByUserId(@Param("userId") Long userId);

    java.util.List<EvaluationVO> listByUserId(@Param("userId") Long userId,
                                               @Param("offset") int offset,
                                               @Param("pageSize") int pageSize);

    Evaluation findById(@Param("id") Long id);

    int updateReply(Evaluation evaluation);
}
