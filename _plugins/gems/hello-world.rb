module Jekyll
  class HelloWorld < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "This _[child section]({{ item_baseline | prepend:'https://' | append: '.github.io/' }})_ is #{@text}"
    end
  end
end

Liquid::Template.register_tag('hello', Jekyll::HelloWorld)
