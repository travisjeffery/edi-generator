module <%= namespace.modulize %>
  class <%= class_name %> < EdiOutbound
    <% if push? %>
    include ::Edi::Push

    def ca_certificate
      self.site.edi_configuration.ca_certificate_for_outbound_<%= edi_code %>_data
    end

    <% end %>
    # belongs_to :unit_shipment, :foreign_key => :source_id

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
  end
end
