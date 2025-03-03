class API::V2::GraphqlController < API::V2::BaseController
  include GraphqlOperationLogConcern

  def execute
    result = API::V2::Schema.execute(query,
      variables: variables,
      context: context,
      operation_name: params[:operationName])

    render json: result
  rescue GraphQL::ParseError, JSON::ParserError => exception
    handle_parse_error(exception)
  rescue => exception
    if Rails.env.production?
      handle_error_in_production(exception)
    else
      handle_error_in_development(exception)
    end
  end

  private

  def append_info_to_payload(payload)
    super

    payload.merge!({
      graphql_operation: operation_log(query(fallback: ''), params[:operationName], to_unsafe_hash(params[:variables]))
    })
  end

  def process_action(*args)
    super
  rescue ActionDispatch::Http::Parameters::ParseError => exception
    render json: {
      errors: [
        { message: exception.cause.message }
      ],
      data: nil
    }, status: 400
  end

  def query(fallback: nil)
    if params[:queryId].present?
      API::V2::StoredQuery.get(params[:queryId], fallback: fallback)
    else
      params[:query]
    end
  end

  def variables
    ensure_hash(params[:variables])
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def to_unsafe_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        JSON.parse(ambiguous_param)
      else
        {}
      end
    when ActionController::Parameters
      ambiguous_param.to_unsafe_h
    else
      ambiguous_param
    end
  rescue JSON::ParserError
    {}
  end

  def handle_parse_error(exception)
    render json: {
      errors: [
        { message: exception.message }
      ],
      data: nil
    }, status: 400
  end

  def handle_error_in_development(exception)
    logger.error exception.message
    logger.error exception.backtrace.join("\n")

    render json: {
      errors: [
        { message: exception.message, backtrace: exception.backtrace }
      ],
      data: nil
    }, status: 500
  end

  def handle_error_in_production(exception)
    id = SecureRandom.uuid
    Sentry.capture_exception(exception, extra: { exception_id: id })

    render json: {
      errors: [
        {
          message: "Internal Server Error",
          extensions: {
            exception: { id: id }
          }
        }
      ],
      data: nil
    }, status: 500
  end
end
