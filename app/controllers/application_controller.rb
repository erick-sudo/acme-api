class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_response

    wrap_parameters format: []

    private

    def record_not_found_response
        render json: { error: "#{controller_name.classify} not found" }, status: :not_found
    end

    def unprocessable_entity_response(invalid)
        render json: { errors: invalid.record.errors }, status: :unprocessable_entity
    end
end
