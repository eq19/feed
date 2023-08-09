module Jekyll
  class HelloWorld < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "This section is #{@text} by [the spin]({{ item_baseline | prepend:"https://" | append: ".github.io/" }})"
    end
  end
end

Liquid::Template.register_tag('hello', Jekyll::HelloWorld)
