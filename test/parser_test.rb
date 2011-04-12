$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'helper'
require 'mustache'
# require '../lib/mustache/parser'

class ParserTest < Test::Unit::TestCase
  def test_parser
    lexer = Mustache::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{header}}</h1>
{{tag_with_args arg1:"hi there"}}
{{#items}}
{{#first}}
  <li><strong>{{name format:"short"}}</strong></li>
{{/first}}
{{#link}}
  <li><a href="{{url}}">{{name}}</a></li>
{{/link}}
{{/items}}

{{#empty}}
<p>The list is empty.</p>
{{/empty}}
EOF

    expected = [:multi,
      [:static, "<h1>"],
      [:mustache, :etag, [:mustache, :fetch, ["header"]]],
      [:static, "</h1>\n"],
      [:mustache, :etag,
        [:mustache, :fetch, ["tag_with_args", {:arg1=>"hi there"}]]],
      [:static, "\n"],
      [:mustache,
        :section,
        [:mustache, :fetch, ["items"]],
        [:multi,
          [:mustache,
            :section,
            [:mustache, :fetch, ["first"]],
            [:multi,
              [:static, "  <li><strong>"],
              [:mustache, :etag, [:mustache, :fetch, ["name", {:format=>"short"}]]],
              [:static, "</strong></li>\n"]],
            %Q'  <li><strong>{{name format:"short"}}</strong></li>\n',
            %w[{{ }}]],
          [:mustache,
            :section,
            [:mustache, :fetch, ["link"]],
            [:multi,
              [:static, "  <li><a href=\""],
              [:mustache, :etag, [:mustache, :fetch, ["url"]]],
              [:static, "\">"],
              [:mustache, :etag, [:mustache, :fetch, ["name"]]],
              [:static, "</a></li>\n"]],
            %Q'  <li><a href="{{url}}">{{name}}</a></li>\n',
            %w[{{ }}]]],
        %Q'{{#first}}\n  <li><strong>{{name format:"short"}}</strong></li>\n{{/first}}\n{{#link}}\n  <li><a href="{{url}}">{{name}}</a></li>\n{{/link}}\n',
        %w[{{ }}]],
      [:static, "\n"],
      [:mustache,
        :section,
        [:mustache, :fetch, ["empty"]],
        [:multi, [:static, "<p>The list is empty.</p>\n"]],
        %Q'<p>The list is empty.</p>\n',
        %w[{{ }}]]]

    assert_equal expected, tokens
  end

  def test_raw_content_and_whitespace
    lexer = Mustache::Parser.new
    tokens = lexer.compile("{{#list}}\t{{/list}}")

    expected = [:multi,
      [:mustache,
        :section,
        [:mustache, :fetch, ["list"]],
        [:multi, [:static, "\t"]],
        "\t",
        %w[{{ }}]]]

    assert_equal expected, tokens
  end
end
