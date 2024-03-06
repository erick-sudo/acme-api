class InvoicesController < ApplicationController
    def index
        pp pagination_params[:page]
        page_number = pagination_params[:page].to_i
        unless page_number > 0
            page_number = 1
        end
        page_size = pagination_params[:size].to_i
        unless page_size > 0
            page_size = 10
        end
        render json: Invoice.all.order("created_at DESC").paginate(page: page_number, per_page: page_size)
    end

    def count
        render json: { count: Invoice.count }
    end

    def create
        render json: Invoice.create!(invoice_params), status: :created
    end

    def show
        render json: find_invoice
    end

    def update
        invoice = find_invoice
        invoice.update!(invoice_params)
        render json: invoice, status: :accepted
    end

    def destroy
        invoice = find_invoice
        invoice.destroy
        head :no_content
    end

    def search_count
        sql = <<-SQL
        SELECT COUNT(*) AS count
        FROM invoices
        JOIN customers ON invoices.customer_id = customers.id
        WHERE
            customers.name::text ILIKE $1 OR
            customers.email::text ILIKE $2 OR
            invoices.amount::text ILIKE $3 OR
            invoices.created_at::text ILIKE $4 OR
            invoices.status::text ILIKE $5
        SQL

        result = ApplicationRecord.connection.exec_query(sql, "Count Invoices", [*(1..5).map { "%#{search_params[:query]}%" }])

        render json: result.as_json.first
    end

    def latest_invoices
        sql = <<-SQL
        SELECT
            invoices.id,
            customers.name,
            customers.email,
            customers.image_url,
            invoices.amount
        FROM invoices
        JOIN customers ON invoices.customer_id = customers.id
        ORDER BY invoices.created_at DESC
        LIMIT 5
        SQL

        result = ApplicationRecord.connection.exec_query(sql, "Search Invoices")

        render json: result.as_json
    end

    def search_invoices
        sql = <<-SQL
        SELECT
            invoices.id,
            invoices.amount,
            invoices.created_at,
            invoices.status,
            invoices.customer_id,
            customers.name,
            customers.email,
            customers.image_url
        FROM invoices
        JOIN customers ON invoices.customer_id = customers.id
        WHERE
            customers.name::text ILIKE $1 OR
            customers.email::text ILIKE $2 OR
            invoices.amount::text ILIKE $3 OR
            invoices.created_at::text ILIKE $4 OR
            invoices.status::text ILIKE $5
        ORDER BY customers.name ASC
        LIMIT $6
        OFFSET $7
        SQL

        page_number = search_params[:page].to_i - 1
        unless page_number >= 0
            page_number = 0
        end
        page_size = search_params[:size].to_i
        unless page_size > 0
            page_size = 10
        end

        result = ApplicationRecord.connection.exec_query(sql, "Search Invoices", [*(1..5).map { "%#{search_params[:query]}%" }, page_size, (page_number * page_size) ])

        render json: result.as_json
    end

    private

    def find_invoice
        Invoice.find(params[:id])
    end

    def invoice_params
        params.permit(
            :id,
            :customer_id,
            :amount,
            :status
        )
    end

    def pagination_params
        params.permit(
            :page,
            :size
        )
    end

    def search_params
        params.permit(
            :query,
            :page,
            :size
        )
    end
end
