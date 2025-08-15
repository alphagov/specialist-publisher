Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :cookie
  strategy :default

  # Other strategies:
  #
  # strategy :sequel
  # strategy :redis
  #
  # strategy :query_string
  # strategy :session
  #
  # strategy :my_strategy do |feature|
  #   # ... your custom code here; return true/false/nil.
  # end

  feature :live_target_stack_override,
          default: false,
          description: "Sets the target_stack to live. This is restricted to the integration and staging environments only, and is used to override the target stack for testing purposes."
end
