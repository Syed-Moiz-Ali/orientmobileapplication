package com.orient.workshop.owner.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfWriter;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.core.model.entity.Customer;
import com.orient.workshop.core.repository.CustomerMapper;
import com.orient.workshop.owner.model.entity.Invoice;
import com.orient.workshop.owner.repository.InvoiceMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * P3 (audit): invoice PDF generation — the first real PDF export
 * (previously every "download receipt / export" affordance was a no-op).
 */
@Service
@RequiredArgsConstructor
public class InvoicePdfService {

    private final InvoiceMapper invoiceMapper;
    private final CustomerMapper customerMapper;

    public byte[] generate(Long invoiceId) {
        Invoice inv = invoiceMapper.selectById(invoiceId);
        if (inv == null) throw new NotFoundException("Invoice not found: " + invoiceId);
        Customer customer = inv.getCustomerId() != null
                ? customerMapper.selectById(inv.getCustomerId()) : null;

        Document document = new Document(PageSize.A4, 36, 36, 36, 36);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            PdfWriter.getInstance(document, out);
            document.open();

            document.add(new Paragraph("ORIENT WORKSHOP", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18)));
            document.add(new Paragraph("INVOICE", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 24)));
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Invoice No: " + inv.getInvoiceRef()));
            document.add(new Paragraph("Issued: " + (inv.getIssuedDate() != null ? inv.getIssuedDate() : "")));
            document.add(new Paragraph("Due: " + (inv.getDueDate() != null ? inv.getDueDate() : "")));
            document.add(new Paragraph("Status: " + (inv.getStatus() != null ? inv.getStatus() : "")));
            document.add(new Paragraph(" "));
            document.add(new Paragraph("Bill To: " + (customer != null && customer.getCustomerName() != null
                    ? customer.getCustomerName() : "—")));
            if (customer != null && customer.getPhoneNumber() != null && !customer.getPhoneNumber().isBlank()) {
                document.add(new Paragraph("Phone: " + customer.getPhoneNumber()));
            }
            document.add(new Paragraph(" "));

            BigDecimal taxRate = inv.getTaxRate() != null ? inv.getTaxRate() : BigDecimal.ZERO;
            BigDecimal taxAmount = inv.getTaxAmount() != null ? inv.getTaxAmount() : BigDecimal.ZERO;
            BigDecimal grandTotal = inv.getGrandTotal() != null ? inv.getGrandTotal()
                    : (inv.getAmount() != null ? inv.getAmount() : BigDecimal.ZERO);

            document.add(new Paragraph("Subtotal: " + fmt(inv.getAmount())));
            if (taxRate.compareTo(BigDecimal.ZERO) > 0) {
                document.add(new Paragraph("VAT (" + taxRate.multiply(BigDecimal.valueOf(100)).setScale(0)
                        + "%): " + fmt(taxAmount)));
            }
            document.add(new Paragraph("GRAND TOTAL: " + fmt(grandTotal)));
            document.close();
            return out.toByteArray();
        } catch (DocumentException e) {
            throw new IllegalStateException("Could not generate invoice PDF", e);
        }
    }

    private String fmt(BigDecimal v) {
        if (v == null) return "AED 0.00";
        return "AED " + v.setScale(2, RoundingMode.HALF_UP).toPlainString();
    }
}
