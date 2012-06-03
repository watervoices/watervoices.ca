require 'spec_helper'

describe "reports/new.html.erb" do
  before(:each) do
    assign(:report, stub_model(Report,
      :reserve => nil,
      :title => "MyString",
      :status => "",
      :message => "MyText"
    ).as_new_record)
  end

  it "renders new report form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => reports_path, :method => "post" do
      assert_select "input#report_reserve", :name => "report[reserve]"
      assert_select "input#report_title", :name => "report[title]"
      assert_select "input#report_status", :name => "report[status]"
      assert_select "textarea#report_message", :name => "report[message]"
    end
  end
end
