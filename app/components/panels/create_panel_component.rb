class Panels::CreatePanelComponent < ApplicationComponent
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    div class: "panel-title" do
      h4(class: "mb-0") { I18n.t("panels.create.title") }
      span class: "badge-manual" do
        I18n.t("panels.create.badge")
      end
    end

    error_messages

    bootstrap_form_with model: @prompt, url: home_path, method: :post, class: "d-flex flex-column gap-3" do |f|
      f.text_area :text,
        label: I18n.t("panels.create.prompt_label"),
        label_class: "form-label fw-semibold text-white",
        placeholder: I18n.t("panels.create.prompt_placeholder"),
        rows: 6,
        class: "prompt-input"

      f.form_group :kind,
        label: { text: I18n.t("panels.create.output_label"), class: "form-label fw-semibold text-white mb-2" } do
        div class: "d-flex gap-3 flex-wrap" do
          f.radio_button :kind,
            "image",
            label: I18n.t("panels.create.image_label"),
            inline: true,
            wrapper_class: "text-white",
            label_class: "ms-1 fw-semibold text-white"
          f.radio_button :kind,
            "video",
            label: I18n.t("panels.create.video_label"),
            inline: true,
            wrapper_class: "text-white",
            label_class: "ms-1 fw-semibold text-white"
        end
      end

      f.submit I18n.t("panels.create.submit"), class: "btn btn-primary w-100 fw-semibold mt-2"
    end
  end

  private

  def error_messages
    return unless @prompt.errors.any?

    div class: "alert alert-danger" do
      ul class: "mb-0 list-unstyled" do
        @prompt.errors.full_messages.each { |msg| li { msg } }
      end
    end
  end
end
