class EdiGenerator < Rails::Generator::NamedBase
  CONTROLLER_ACTIONS = [:show, :index]

  def initialize(args, options={})
    super

    usage if args.empty?

    @args = args
    @options = options

    generate_attributes
  end

  def manifest
    record do |m|
      raise "EDI should be either Inbound or Outbound" unless inbound? || outbound?

      unless options[:skip_model]
        m.directory "app/models/#{namespace}"
        m.directory "test/unit/#{namespace}"

        m.template "#{direction}/model.rb", "app/models/#{namespace}/#{singular_name}.rb"
        m.template "#{direction}/unit_test.rb", "test/unit/#{namespace}/#{singular_name}_test.rb"
      end

      unless options[:skip_controller]
        m.directory "app/controllers/#{namespace}" 
        m.directory "app/views/#{namespace}" 
        m.directory "test/functional/#{namespace}" 

        if outbound?
          CONTROLLER_ACTIONS.each do |action|
            m.template "#{direction}/#{action}.html.erb", "app/views/#{namespace}/#{action}.html.erb" 
          end
        end

        m.template "#{direction}/controller.rb", "app/controllers/#{namespace}/#{controller_name}.rb"
        m.template "#{direction}/functional_test.rb", "test/functional/#{namespace}/#{controller_name}_test.rb"
      end
    end
  end

  def banner 
    <<-EOS
Creates an EDI, with templates for the Controller, Model, View and Observer.

USAGE: ./script/generate edi EdiName namespace:path/of/namespace [source:edi_source] [options]

EXAMPLES:

Outbound: ./script/generate edi edioutbound007 namespace:belvia/hershey/sap source:receipt

Inbound: ./script/generate edi ediinbound007 namespace:belvia/hershey/sap generate:receipt
    EOS
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-model", "Don't generate a model or migration file.") { |v| options[:skip_model] = v }
    opt.on("--skip-controller", "Don't generate controller, helper, or views.") { |v| options[:skip_controller] = v }
    opt.on("--skip-migration", "Don't generate migration file for model.") { |v| options[:skip_migration] = v }
    opt.on("--push", "Conifgure EDI for push.") { |v| options[:push] = v }
  end

  def plural_name
    name.underscore.pluralize
  end

  def singular_name
    "edi_#{direction}#{edi_code}"
  end

  def class_name
    singular_name.camelize
  end

  def plural_class_name
    plural_name.camelize
  end

  def controller_name
    "edi#{edi_code}_controller"
  end

  def test_helper_path
    "test/unit/#{@namepace}/test_helper".gsub(/\/?^?\w+(\/|$)/, "../")
  end

  def edi_name
    if @args.first =~ /^edi/i
      @args.first
    else
      "edi#{@args.first}"
    end
  end

  def edi_code
    @edi_code ||= edi_name[/.*(\d{3,4}).*/i, 1]
  end

  def push?
    options[:push]
  end

  def edi_for
    if inbound?
      edi_generate || edi_source
    else
      edi_source || edi_generate 
    end
  end

  def edi_source
    attribute_value("source")
  end

  def edi_generate
    attribute_value("generate")
  end

  def namespace
    if api_edi_prefix_given?
      (@attributes.select {|attr| attr.name == "namespace"}).first.type.to_s
    else
      "api/edi/#{(@attributes.select {|attr| attr.name == "namespace"}).first.type.to_s}"
    end
  end

  def api_edi_prefix_given?
    attribute_value("namespace") =~ /^\/?api\/edi/
  end

  def attribute_value attribute
    attribute = (@attributes.select {|attr| attr.name == attribute}).first

    if !attribute.nil?
      attribute.type.to_s
    else
      nil
    end
  end

  def direction
    inbound? ? :inbound : :outbound
  end

  def inbound?
    edi_name[/inbound/i] && !edi_name[/outbound/i]
  end

  def outbound?
    edi_name[/outbound/i] && !edi_name[/inbound/i]
  end

  def generate_attributes
    @attributes ||= []

    @args[1..-1].each do |arg|
      # name => type
      @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":")) if arg.include? ":"
    end
  end
end

class String
  def modulize
    (self.split('/').map {|mod| mod.camelize}).join('::')
  end
end

$VERBOSE = nil

