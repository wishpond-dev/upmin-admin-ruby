module Upmin
  class Model

    attr_accessor :rails_model
    attr_accessor :color

    def initialize(rails_model, options = {})
      self.rails_model = rails_model

      if options[:color]
        self.color = options[:color]
      end
    end

    def to_s
      return rails_model.to_s
    end

    def name
      return rails_model.name
    end

    def form_name
      return rails_model.name.underscore
    end
    alias_method :partial_name, :form_name

    # Wrapper methods that the normal model would have access to
    def find(id)
      return rails_model.find(id)
    end

    def search(*args)
      return self.rails_model.ransack(*args)
    end
    alias_method :ransack, :search


    # Methods for determinining attributes, and their types.
    def attributes
      return @attributes if defined?(@attributes)

      attributes = {}
      rails_model.upmin_attributes.each do |u_attr|
        attributes[u_attr] = {}
        attributes[u_attr][:type] = get_attr_type(u_attr)
      end

      return @attributes = attributes
    end

    def get_attr_type(attr_name)
      if uc = rails_model.columns_hash[attr_name.to_s]
        return uc.type
      else
        return :unknown
      end
    end


    ## Generic Class Methods
    def Model.find(name)
      return all.select{|a| a.to_s == name.to_s}.first
    end

    # TODO(jon): Store this in the future so it doesn't have to be looked up every call.
    def Model.all
      return @models_array if defined?(@models_array)
      models_array = []
      colors = [
        :light_blue,
        :blue_green,
        :red,
        :yellow,
        :orange,
        :purple,
        :dark_blue,
        :dark_red,
        :green
      ]

      rails_models.each_with_index do |rails_model, i|
        ac_model = Model.new(rails_model, color: colors[i % colors.length])
        models_array << ac_model
      end

      return @models_array = models_array
    end

    def Model.rails_models
      ::Rails.application.eager_load!
      rails_models = ::ActiveRecord::Base.descendants.select do |m|
        m.to_s != "ActiveRecord::SchemaMigration"
      end

      return rails_models
    end

  end
end
