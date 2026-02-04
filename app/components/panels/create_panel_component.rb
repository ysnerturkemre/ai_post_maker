class Panels::CreatePanelComponent < ApplicationComponent
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    error_messages

    form_with model: @prompt, url: home_path, method: :post, class: "d-flex flex-column h-100 gap-4" do |f|
      div class: "prompt-header" do
        label class: "prompt-header-label" do
          "Vision & Prompt"
        end
        button class: "prompt-reset", type: "reset" do
          span(class: "material-symbols-outlined") { "close" }
          span { "Temizle" }
        end
      end

      f.text_area :text,
        placeholder: I18n.t("panels.create.prompt_placeholder"),
        rows: 8,
        class: "prompt-input flex-grow-1"

      div class: "row g-3" do
        div class: "col-12 col-md-6" do
          div class: "form-stack" do
            label class: "field-label" do
              I18n.t("panels.create.tone_label")
            end
            f.select :tone,
              tone_options,
              { selected: @prompt.tone.presence || LocalCaptionService::DEFAULT_TONE },
              class: "form-select"
          end
        end
        div class: "col-12 col-md-6" do
          div class: "form-stack" do
            label class: "field-label" do
              I18n.t("panels.create.lang_label")
            end
            f.select :lang,
              lang_options,
              { selected: @prompt.lang.presence || LocalCaptionService::DEFAULT_LANG },
              class: "form-select"
          end
        end
      end

      div class: "form-stack" do
        label class: "field-label" do
          I18n.t("panels.create.output_label")
        end
        div class: "format-toggle" do
          div class: "format-option" do
            input type: "radio",
              name: "prompt[kind]",
              value: "image",
              id: "prompt_kind_image",
              class: "format-input",
              checked: current_kind == "image"
            label for: "prompt_kind_image", class: "format-label" do
              span(class: "material-symbols-outlined") { "photo_library" }
              span { I18n.t("panels.create.image_label") }
            end
          end
          div class: "format-option" do
            input type: "radio",
              name: "prompt[kind]",
              value: "video",
              id: "prompt_kind_video",
              class: "format-input",
              disabled: true,
              checked: current_kind == "video"
            label for: "prompt_kind_video", class: "format-label" do
              span(class: "material-symbols-outlined") { "play_circle" }
              span { I18n.t("panels.create.video_label") }
            end
          end
        end
        div class: "form-text text-white-50 mt-2" do
          I18n.t("panels.create.video_help")
        end
      end

      button class: "btn btn-generate w-100", type: "submit" do
        span(class: "material-symbols-outlined") { "bolt" }
        span { I18n.t("panels.create.submit") }
      end
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

  def lang_options
    [
      ["1:1 Square", "tr"],
      ["9:16 Reel", "en"]
    ]
  end

  def tone_options
    [
      ["Professional", "formal"],
      ["Aesthetic", "friendly"],
      ["Bold", "friendly"]
    ]
  end

  def current_kind
    value = @prompt&.kind.to_s
    value.presence || "image"
  end
end
