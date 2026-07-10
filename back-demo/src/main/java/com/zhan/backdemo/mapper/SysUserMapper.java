package com.zhan.backdemo.mapper;

import com.zhan.backdemo.entity.SysUser;
import com.zhan.backdemo.vo.ResidentListVO;
import com.zhan.backdemo.vo.WorkerListVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SysUserMapper {

    SysUser findByUsername(@Param("username") String username);

    SysUser findById(@Param("id") Long id);

    SysUser findByPhone(@Param("phone") String phone);

    int insert(SysUser user);

    int update(SysUser user);

    int deleteById(@Param("id") Long id);

    long countWorkers(@Param("name") String name,
                      @Param("phone") String phone,
                      @Param("status") String status);

    List<WorkerListVO> listWorkers(@Param("name") String name,
                                   @Param("phone") String phone,
                                   @Param("status") String status,
                                   @Param("offset") int offset,
                                   @Param("pageSize") int pageSize);

    long countResidents(@Param("name") String name,
                        @Param("phone") String phone);

    List<ResidentListVO> listResidents(@Param("name") String name,
                                       @Param("phone") String phone,
                                       @Param("offset") int offset,
                                       @Param("pageSize") int pageSize);

    List<SysUser> listByRole(@Param("role") String role);

    List<SysUser> listActiveWorkers();
}
