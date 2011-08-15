module <%= namespace.modulize %>
  class <%= class_name %> < EdiOutbound
<% if push? %>
    include ::Edi::Push

    def ca_certificate
      self.site.edi_configuration.ca_certificate_for_outbound_<%= edi_code %>_data
    end
<% end %>

<% if edi_for %>
    belongs_to :<%= edi_for %>, :foreign_key => :source_id

    def source
      self.<%= edi_for %>
    end

    def self.view_model
      "<%= edi_for.pluralize %>"
    end

    def self.label_name
      "<%= edi_for.titleize %> -> EDI <%= edi_code %>"
    end

    def self.dropdown_name
      "EDI <%= edi_code %>"
    end
<% else %>
    def source
      raise "Implement me!"
    end

    def create_edi_log
      raise "Implement me!" 
    end 

    def self.dropdown_name 
      raise "Implement me!"
    end 

    def self.label_name 
      raise "Implement me!"
    end 
<% end %>
  end
end
