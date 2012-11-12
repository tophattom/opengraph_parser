require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpenGraph do
  describe "#initialize" do
    context "with invalid src" do
      it "should set title and url the same as src" do
        og = OpenGraph.new("invalid")
        og.src.should == "invalid"
        og.title.should == "invalid"
        og.url.should == "invalid"
      end
    end

    context "with no fallback" do
      it "should get values from opengraph metadata" do
        response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph.html", 'r') { |f| f.read })
        RedirectFollower.stub(:new) { double(resolve: response) }

        og = OpenGraph.new("http://test.host", false)
        og.src.should == "http://test.host"
        og.title.should == "OpenGraph Title"
        og.type.should == "article"
        og.url.should == "http://test.host"
        og.description.should == "My OpenGraph sample site for Rspec"
        og.images.should == ["http://test.host/images/rock1.jpg", "http://test.host/images/rock2.jpg"]
      end
    end

    context "with fallback" do
      context "when website has opengraph metadata" do
        it "should get values from opengraph metadata" do
          response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph.html", 'r') { |f| f.read })
          RedirectFollower.stub(:new) { double(resolve: response) }

          og = OpenGraph.new("http://test.host")
          og.src.should == "http://test.host"
          og.title.should == "OpenGraph Title"
          og.type.should == "article"
          og.url.should == "http://test.host"
          og.description.should == "My OpenGraph sample site for Rspec"
          og.images.should == ["http://test.host/images/rock1.jpg", "http://test.host/images/rock2.jpg"]
        end
      end

      context "when website has no opengraph metadata" do
        it "should lookup for other data from website" do
          response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph_no_metadata.html", 'r') { |f| f.read })
          RedirectFollower.stub(:new) { double(resolve: response) }

          og = OpenGraph.new("http://test.host")
          og.src.should == "http://test.host"
          og.title.should == "OpenGraph Title Fallback"
          og.type.should be_nil
          og.url.should == "http://test.host"
          og.description.should == "Short Description Fallback"
          og.images.should == ["http://test.host:80/images/wall1.jpg", "http://test.host:80/images/wall2.jpg"]
        end
      end
    end
  end
end