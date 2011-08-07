# TODO: add --push argument

class String
  def modulize
    (self.split('/').map {|mod| mod.camelize}).join('::')
  end
end

class EdiGenerator < Rails::Generator::NamedBase
  attr_accessor :name, :attributes

  CONTROLLER_ACTIONS = [:show, :index]

  def initialize(args, options={})

    super
    usage if args.empty?

    @name = args.first
    @args = args
    @options = options
    @attributes = []

    generate_attributes
  end

  def manifest
    record do |m|
      raise "EDI should be either Inbound or Outbound" unless inbound? || outbound?

      direction = inbound? ? :inbound : :outbound

      unless options[:skip_model]
        m.directory "app/models/#{namespace}"
        m.template "#{direction}/model.rb", "app/models/#{namespace}/#{singular_name}.rb"
      end

      unless options[:skip_controller]
        m.directory "app/controllers/#{namespace}" 
        m.directory "app/views/#{namespace}" 

        CONTROLLER_ACTIONS.each do |action|
          m.template "#{direction}/#{action}.html.erb", "app/views/#{namespace}/#{action}.html.erb" 
        end
        m.template "#{direction}/controller.rb", "app/controllers/#{namespace}/#{controller_name}.rb"
      end
    end
  end

  protected

  def banner 
    <<-EOS
Creates an EDI, with templates for the Controller, Model, View and Observer.

USAGE: ./script/generate edi EdiName [model_field:value] [options]
    EOS
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-model", "Don't generate a model or migration file.") { |v| options[:skip_model] = v }
    opt.on("--skip-controller", "Don't generate controller, helper, or views.") { |v| options[:skip_controller] = v }
    opt.on("--skip-migration", "Don't generate migration file for model.") { |v| options[:skip_migration] = v }
    opt.on("--skip-timestamps", "Don't add timestamps to migration file.") { |v| options[:skip_timestamps] = v }
    opt.on("--invert", "Generate all controller actions except these mentioned.") { |v| options[:invert] = v }
    opt.on("--haml", "Generate HAML views instead of ERB.") { |v| options[:haml] = v }
    opt.on("--testunit", "Use test/unit for test files.") { options[:test_framework] = :testunit }
    opt.on("--shoulda", "Use Shoulda for test files.") { options[:test_framework] = :shoulda }
  end

  private

  def plural_name
    name.underscore.pluralize
  end

  def singular_name
    name.underscore
  end

  def class_name
    name.camelize
  end
  alias_method :model_name, :class_name

  def plural_class_name
    plural_name.camelize
  end

  def controller_name
    "edi#{edi_code}_controller"
  end

  def edi_code
    @edi_code ||= @name[/.*(\d{3,4}).*/i, 1]
  end

  def namespace
    @given_namespace ||= @attributes.select {|attr| attr.name == "namespace"}.first.type.to_s
    @namespace ||= "api/edi/#{@given_namespace}" unless api_edi_prefix_given?
    @namespace ||= @given_namespace
  end

  def api_edi_prefix_given?
    namespace[/^api\/edi/]
  end

  def inbound?
    @name[/inbound/i] && !@name[/outbound/i]
  end

  def outbound?
    @name[/outbound/i] && !@name[/inbound/i]
  end

  def generate_attributes
    @args[1..-1].each do |arg|
      # name => type
      @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":")) if arg.include? ":"
    end
  end
end
