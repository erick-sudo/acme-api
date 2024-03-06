class DashboardController < ApplicationController

    def counts

        totalInvoicesSql = <<-SQL
            SELECT
                SUM(CASE WHEN status = $1 THEN amount ELSE 0 END) AS "paid" ,
                SUM(CASE WHEN status = $2 THEN amount ELSE 0 END) AS "pending"
            FROM invoices
        SQL

        result = ApplicationRecord.connection.exec_query(totalInvoicesSql, "Tally Invoices", ["paid", "pending"]).first

        render json: {
            numberOfCustomers: Customer.count,
            numberOfInvoices: Invoice.count,
            totalPaidInvoices: result["paid"],
            totalPendingInvoices: result["pending"]
        }
    end
end
