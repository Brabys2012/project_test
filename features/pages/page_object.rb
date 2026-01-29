# frozen_string_literal: true

# Фабрика страниц: создание экземпляров страниц для шагов.
class PageObject
  extend BaseModules

  def self.create_instance(class_name, **args)
    args.empty? ? class_name.new : class_name.new(**args)
  end
end
