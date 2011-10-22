# encoding: utf-8
require "spec_helper"

describe BestInPlace::BestInPlaceHelpers do
  describe "#best_in_place" do
    before do
      @user = User.new :name => "Lucia",
        :last_name => "Napoli",
        :email => "lucianapoli@gmail.com",
        :address => "Via Roma 99",
        :zip => "25123",
        :country => "2",
        :receive_email => false,
        :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem."
    end

    it "should generate a proper span" do
      nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
      span = nk.css("span")
      span.should_not be_empty
    end

    describe "general properties" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      it "should have a proper id" do
        @span.attribute("id").value.should == "best_in_place_user_name"
      end

      it "should have the best_in_place class" do
        @span.attribute("class").value.should == "best_in_place"
      end

      it "should have the correct data-attribute" do
        @span.attribute("data-attribute").value.should == "name"
      end

      it "should have the correct data-object" do
        @span.attribute("data-object").value.should == "user"
      end

      it "should have no activator by default" do
        @span.attribute("data-activator").should be_nil
      end

      it "should have no inner_class by default" do
        @span.attribute("data-inner-class").should be_nil
      end

      describe "url generation" do
        it "should have the correct default url" do
          @user.save!
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/users/#{@user.id}"
        end

        it "should use the custom url specified in string format" do
          out = helper.best_in_place @user, :name, :path => "/custom/path"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/custom/path"
        end

        it "should use the path given in a named_path format" do
          out = helper.best_in_place @user, :name, :path => helper.users_path
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/users"
        end

        it "should use the given path in a hash format" do
          out = helper.best_in_place @user, :name, :path => {:controller => :users, :action => :edit, :id => 23}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/users/23/edit"
        end
      end

      describe "nil option" do
        it "should have no nil data by default" do
          @span.attribute("data-nil").should be_nil
        end

        it "should show '' if the object responds with nil for the passed attribute" do
          @user.stub!(:name).and_return(nil)
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          span.text.should == ""
        end

        it "should show '' if the object responds with an empty string for the passed attribute" do
          @user.stub!(:name).and_return("")
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          span.text.should == ""
        end
      end

      it "should have the given inner_class" do
        out = helper.best_in_place @user, :name, :inner_class => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-inner-class").value.should == "awesome"
      end

      it "should have the given activator" do
        out = helper.best_in_place @user, :name, :activator => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-activator").value.should == "awesome"
      end
    end


    context "with a text field attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      it "should render the name as text" do
        @span.text.should == "Lucia"
      end

      it "should have an input data-type" do
        @span.attribute("data-type").value.should == "input"
      end

      it "should have no data-collection" do
        @span.attribute("data-collection").should be_nil
      end
    end

    context "with a boolean attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox)
        @span = nk.css("span")
      end

      it "should have a checkbox data-type" do
        @span.attribute("data-type").value.should == "checkbox"
      end

      it "should have the default data-collection" do
        data = ["No", "Yes"]
        @span.attribute("data-collection").value.should == data.to_json
      end

      it "should render the current option as No" do
        @span.text.should == "No"
      end

      describe "custom collection" do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox, :collection => ["Nain", "Da"])
          @span = nk.css("span")
        end

        it "should show the message with the custom values" do
          @span.text.should == "Nain"
        end

        it "should render the proper data-collection" do
          @span.attribute("data-collection").value.should == ["Nain", "Da"].to_json
        end
      end

    end

    context "with a select attribute" do
      before do
        @countries = COUNTRIES.to_a
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, :type => :select, :collection => @countries)
        @span = nk.css("span")
      end

      it "should have a select data-type" do
        @span.attribute("data-type").value.should == "select"
      end

      it "should have a proper data collection" do
        @span.attribute("data-collection").value.should == @countries.to_json
      end

      it "should show the current country" do
        @span.text.should == "Italy"
      end
    end

  end

  describe "JS behaviour", :js => true, :pending => true do
    describe "nil option" do
      it "should render the default '-' string when the field is empty"
      it "should render the passed nil value if the field is empty"
    end
  end
end