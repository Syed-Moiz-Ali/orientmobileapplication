package com.orient.workshop.owner.controller;

import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.owner.service.InvoicePdfService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/invoices")
@RequiredArgsConstructor
public class InvoicePdfController {

    private final InvoicePdfService invoicePdfService;

    /**
     * P3 (audit): real invoice PDF — previously every "download receipt"
     * affordance was a no-op.
     */
    @GetMapping(value = "/{id}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
    public void pdf(@PathVariable Long id, HttpServletResponse response) throws IOException {
        byte[] bytes = invoicePdfService.generate(id);
        response.setContentType(MediaType.APPLICATION_PDF_VALUE);
        response.setHeader("Content-Disposition", "attachment; filename=invoice-" + id + ".pdf");
        response.setContentLength(bytes.length);
        response.getOutputStream().write(bytes);
        response.getOutputStream().flush();
    }
}
