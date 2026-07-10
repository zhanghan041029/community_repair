package com.zhan.backdemo.mapper;

import com.zhan.backdemo.entity.RepairOrder;
import com.zhan.backdemo.vo.RepairDetailVO;
import com.zhan.backdemo.vo.RepairListVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface RepairOrderMapper {

    int insert(RepairOrder order);

    RepairOrder findById(@Param("id") Long id);

    RepairDetailVO findDetailById(@Param("id") Long id);

    int update(RepairOrder order);

    int deleteById(@Param("id") Long id);

    long countRepairs(@Param("role") String role,
                      @Param("userId") Long userId,
                      @Param("title") String title,
                      @Param("status") String status,
                      @Param("residentName") String residentName,
                      @Param("workerName") String workerName,
                      @Param("startTime") String startTime,
                      @Param("endTime") String endTime);

    List<RepairListVO> listRepairs(@Param("role") String role,
                                   @Param("userId") Long userId,
                                   @Param("title") String title,
                                   @Param("status") String status,
                                   @Param("residentName") String residentName,
                                   @Param("workerName") String workerName,
                                   @Param("startTime") String startTime,
                                   @Param("endTime") String endTime,
                                   @Param("offset") int offset,
                                   @Param("pageSize") int pageSize);

    int countIncompleteByWorkerId(@Param("workerId") Long workerId);

    int countIncompleteByResidentId(@Param("residentId") Long residentId);

    long countByUserIdAndStatus(@Param("userId") Long userId, @Param("status") String status);

    long countByStatus(@Param("status") String status);

    List<Map<String, Object>> countDaily(@Param("startDate") String startDate, @Param("endDate") String endDate);

    List<RepairListVO> listRecent(@Param("limit") int limit);
}
