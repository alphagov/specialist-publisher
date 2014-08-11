require "fast_spec_helper"

require "footnotes_section_heading_renderer"

RSpec.describe FootnotesSectionHeadingRenderer do
  subject(:renderer) {
    FootnotesSectionHeadingRenderer.new(document)
  }

  let(:document) { double(:document, body: html_fragment) }

  context "with footnotes in the document body" do
    let(:html_fragment) {
      %q{
        <h2 id="heading">First heading</h2>
        <p>
          Lorem ipsum dolor sit amet
          <sup id="fnref:1">
            <a href="#fn:1" rel="footnote">1</a>
          </sup>
        </p>
        <div class="footnotes">
          <ol>
            <li id="fn:1">
              <p>Footnote text<a href="#fnref:1" rel="reference">↩</a></p>
            </li>
          </ol>
        </div>
      }
    }

    let(:expected_html) {
      %q{
        <h2 id="heading">First heading</h2>
        <p>
          Lorem ipsum dolor sit amet
          <sup id="fnref:1">
            <a href="#fn:1" rel="footnote">1</a>
          </sup>
        </p>
        <h2 id="footnotes">Footnotes</h2><div class="footnotes">
          <ol>
            <li id="fn:1">
              <p>Footnote text<a href="#fnref:1" rel="reference">↩</a></p>
            </li>
          </ol>
        </div>
      }
    }

    it "adds a heading to the footnotes section" do
      expect(renderer.body).to eq(expected_html)
    end
  end

  context "with no footnotes in the body" do
    let(:html_fragment) {
      %q{
        <h2 id="the-first-heading">The first heading</h2>
        <p>
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus
          vulputate nec purus ut fermentum. Mauris sed nisl at arcu tincidunt
          accumsan. Quisque ac nunc commodo, tempor justo volutpat, bibendum
          velit.
        </p>
        <h2 id="consequat-pretium">Consequat pretium</h2>
        <p>
          Curabitur a volutpat odio. Quisque dui mi, tincidunt a bibendum ac,
          porta sit amet tellus. Donec sollicitudin quam sapien, vel sodales nisl
          ullamcorper vitae. Nullam rhoncus, eros vulputate tincidunt facilisis,
          lorem nunc facilisis mauris, commodo tincidunt nunc leo ac est.
        </p>
      }
    }

    it "doesn't add a footnotes heading where none is necessary" do
      expect(renderer.body).to eq(html_fragment)
    end
  end
end
