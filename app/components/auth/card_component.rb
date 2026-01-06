class Auth::CardComponent < ApplicationComponent
  def initialize(title:, subtitle:)
    @title = title
    @subtitle = subtitle
  end

  def view_template(&block)
    div class: "min-vh-100 d-flex align-items-center justify-content-center py-5 w-100",
      style: "background: linear-gradient(145deg, #5963c2 0%, #6f7ad8 50%, #8a94ec 100%);" do
      div class: "card border-0 shadow-lg w-100 bg-white bg-opacity-15 position-relative",
        style: "max-width: 450px; border-radius: 1.5rem; overflow: visible;" do

        language_dropdown

        div class: "card-body p-4 p-md-5 position-relative" do
          header_bar
          title_section
          block.call if block
        end
      end
    end
  end

  private

  def header_bar
    div class: "d-flex align-items-center justify-content-between mb-4" do
      div class: "d-flex align-items-center gap-3" do
        div class: "rounded-circle bg-primary text-white d-flex align-items-center justify-content-center fw-bold",
          style: "width: 44px; height: 44px;" do
          "AI"
        end
        span(class: "fw-semibold text-body-emphasis") { "AI Post Maker" }
      end
    end
  end

  def title_section
    div class: "mb-3" do
      h4(class: "mb-1 fw-bold text-body-emphasis") { @title }
      small(class: "text-muted") { @subtitle }
    end
  end

  def language_dropdown
    params_locale = view_context.respond_to?(:params) ? view_context.params[:locale] : nil
    current_label = params_locale == "en" ? "English" : "Türkçe"

    div class: "position-absolute top-0 end-0 m-3", style: "z-index: 10;" do
      div class: "dropdown" do
        button class: "btn btn-outline-dark rounded-pill d-inline-flex align-items-center px-3 py-1 dropdown-toggle",
          type: "button",
          role: "button",
          data: { bs_toggle: "dropdown" },
          aria: { expanded: "false" } do
          span(class: "me-2") { "🌐" }
          span(class: "me-1") { current_label }
        end

        ul class: "dropdown-menu dropdown-menu-end" do
          li do
            a href: "?locale=tr",
              class: "dropdown-item" do
              "Türkçe"
            end
          end
          li do
            a href: "?locale=en",
              class: "dropdown-item" do
              "English"
            end
          end
        end
      end
    end
  end
end
