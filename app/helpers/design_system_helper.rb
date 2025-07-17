# Temporary helper to encapsulate layout helper methods.
# To be removed when we are fully migrated to new design system
module DesignSystemHelper
  def get_layout
    if self.class::DESIGN_SYSTEM_MIGRATED_ACTIONS.include?(action_name) && Flipflop.enabled?(:show_design_system)
      "design_system"
    else
      "legacy_application"
    end
  end

  def design_system_view(design_system_view, legacy_view)
    get_layout == "design_system" ? design_system_view : legacy_view
  end
end
