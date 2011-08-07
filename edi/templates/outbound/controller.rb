module <%= namespace.modulize %>
  class <%= controller_name.camelize %>< ApiController
    include ::Edi::OutboundRequestHandler

    protected

    def edi_class
      <%= class_name %>
    end

    def edi_prefix
      "<%= namespace.modulize %>::<%= class_name %>"
    end
  end
end
