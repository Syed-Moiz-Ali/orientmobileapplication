package com.orient.workshop.auth.service;

import com.orient.workshop.auth.repository.OtpRecordMapper;
import org.junit.jupiter.api.Test;
import org.springframework.core.env.Environment;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;

class OtpServiceFixedValueTest {

    @Test
    void explicitProductionTestSwitchAllowsConfiguredFixedOtp() {
        OtpService service = new OtpService(
                mock(OtpRecordMapper.class),
                mock(Environment.class));

        ReflectionTestUtils.setField(service, "fixedOtpValue", "123456");
        ReflectionTestUtils.setField(service, "allowFixedOtpInProduction", true);

        String generatedOtp = ReflectionTestUtils.invokeMethod(service, "generateOtp");

        assertEquals("123456", generatedOtp);
    }
}
