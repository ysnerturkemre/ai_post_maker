module Views; end

# Load Phlex views from app/views under the Views namespace.
Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"),
  namespace: Views
)
