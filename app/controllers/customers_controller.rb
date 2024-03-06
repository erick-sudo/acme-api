class CustomersController < ApplicationController
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
        render json: Customer.all.paginate(page: page_number, per_page: page_size)
    end

    def count
        render json: { count: Customer.count }
    end

    def create
        render json: Customer.create!(customer_params), status: :created
    end

    def show
        render json: find_customer
    end

    def update
        customer = find_customer
        customer.update!(customer_params)
        render json: customer, status: :accepted
    end

    def destroy
        customer = find_customer
        customer.destroy
        head :no_content
    end

    def search_count
        sql = <<-SQL
        SELECT COUNT(*) AS count
        FROM customers
        WHERE
            customers.name::text ILIKE $1 OR
            customers.email::text ILIKE $2
        SQL

        result = ApplicationRecord.connection.exec_query(sql, "Count Customers", [*(1..2).map { "%#{search_params[:query]}%" }])

        render json: result.as_json.first
    end

    def search_customers
        sql = <<-SQL
        SELECT
            customers.id,
            customers.name,
            customers.email,
            customers.image_url,
            COUNT(invoices.id) AS total_invoices,
            SUM(CASE WHEN invoices.status = 'pending' THEN invoices.amount ELSE 0 END) AS total_pending,
            SUM(CASE WHEN invoices.status = 'paid' THEN invoices.amount ELSE 0 END) AS total_paid
        FROM customers
        LEFT JOIN invoices ON customers.id = invoices.customer_id
        WHERE
            customers.name::text ILIKE $1 OR
            customers.email::text ILIKE $2
        GROUP BY customers.id, customers.name, customers.email, customers.image_url
        ORDER BY customers.name ASC
        LIMIT $3
        OFFSET $4
        SQL

        page_number = search_params[:page].to_i - 1
        unless page_number >= 0
            page_number = 0
        end
        page_size = search_params[:size].to_i
        unless page_size > 0
            page_size = 10
        end

        result = ApplicationRecord.connection.exec_query(sql, "Search Customers", [*(1..2).map { "%#{search_params[:query]}%" }, page_size, (page_number * page_size) ])

        render json: result.as_json
    end

    private

    def find_customer
        Customer.find(params[:id])
    end

    def customer_params
        params.permit(
            :name,
            :email,
            :image_url,
            :id
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
