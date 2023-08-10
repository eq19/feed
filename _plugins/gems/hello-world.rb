module Jekyll
  class HelloWorld < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "This _child section_ is #{@text}"
    end
  end
end

Liquid::Template.register_tag('hello', Jekyll::HelloWorld)
