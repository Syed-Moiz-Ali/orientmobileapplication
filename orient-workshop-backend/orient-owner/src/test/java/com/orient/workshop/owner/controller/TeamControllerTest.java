package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.model.entity.User;
import com.orient.workshop.auth.repository.UserMapper;
import com.orient.workshop.auth.service.PasswordService;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.Staff;
import com.orient.workshop.core.repository.StaffMapper;
import com.orient.workshop.owner.model.dto.StaffMemberRequest;
import com.orient.workshop.owner.model.dto.StaffMemberResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.invocation.InvocationOnMock;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class TeamControllerTest {

    private StaffMapper staffMapper;
    private UserMapper userMapper;
    private PasswordService passwordService;
    private TeamController controller;

    @BeforeEach
    void setUp() {
        staffMapper = mock(StaffMapper.class);
        userMapper = mock(UserMapper.class);
        passwordService = mock(PasswordService.class);
        controller = new TeamController(staffMapper, userMapper, passwordService);
    }

    @Test
    void createStaffReturnsLoginEmailAndPhoneFromLinkedUser() {
        when(staffMapper.findAnyByEmpId("ADV100")).thenReturn(Optional.empty());
        when(userMapper.findByPhone("971501111111")).thenReturn(Optional.empty());
        when(userMapper.findByEmail("advisor@example.com")).thenReturn(Optional.empty());
        when(passwordService.hash("password123")).thenReturn("hashed");
        when(userMapper.insert(any(User.class))).thenAnswer(this::assignUserId);
        when(staffMapper.insert(any(Staff.class))).thenAnswer(invocation -> {
            invocation.<Staff>getArgument(0).setId(44L);
            return 1;
        });

        StaffMemberRequest request = StaffMemberRequest.builder()
                .name("API Advisor")
                .empId("ADV100")
                .role("advisor")
                .phone("971501111111")
                .email("Advisor@Example.com")
                .password("password123")
                .branchId(1L)
                .branch("Main Branch")
                .build();

        ApiResponse<StaffMemberResponse> response = controller.createStaff(request);

        assertEquals(200, response.getCode());
        assertEquals("advisor@example.com", response.getData().getEmail());
        assertEquals("971501111111", response.getData().getPhone());
        assertEquals(9L, response.getData().getUserId());
        assertEquals(44L, response.getData().getId());
    }

    @Test
    void listStaffEnrichesEveryStaffRecordWithLinkedUserCredentials() {
        Staff staff = Staff.builder()
                .id(44L)
                .userId(9L)
                .empId("ADV100")
                .name("API Advisor")
                .role("advisor")
                .isActive(true)
                .build();
        User user = User.builder()
                .id(9L)
                .email("advisor@example.com")
                .phone("971501111111")
                .build();
        when(staffMapper.selectList(null)).thenReturn(List.of(staff));
        when(userMapper.selectBatchIds(any())).thenReturn(List.of(user));

        List<StaffMemberResponse> result = controller.listStaff().getData();

        assertEquals(1, result.size());
        assertEquals("advisor@example.com", result.get(0).getEmail());
        assertEquals("971501111111", result.get(0).getPhone());
        assertTrue(result.get(0).getIsActive());
    }

    private int assignUserId(InvocationOnMock invocation) {
        invocation.<User>getArgument(0).setId(9L);
        return 1;
    }
}
