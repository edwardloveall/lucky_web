class Lucky::ErrorHandler
  include HTTP::Handler

  Habitat.create do
    setting show_debug_output : Bool
  end

  private getter action

  def initialize(@action : Lucky::ErrorAction.class)
  end

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue error : Exception
    if settings.show_debug_output
      print_debug_output(context, error)
    else
      call_error_action(context, error)
    end
  end

  private def print_debug_output(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    context.response.reset
    context.response.status_code = 500
    context.response.content_type = "text/html"
    context.response.print Lucky::ExceptionPage.for_runtime_exception(context, error)
    context
  end

  private def call_error_action(context : HTTP::Server::Context, error : Exception) : HTTP::Server::Context
    context.response.status_code = 500
    action.new(context).perform_action(error)
    context
  end
end
