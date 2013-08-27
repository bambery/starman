require_relative 'spec_helper'
require_relative '../post.rb'

describe Post, "#initialize" do
  context 'valid post name' do

    before(:each) do
      Post.stub(:exists?) { true }
      Post.any_instance.stub(:read_post_file) { FactoryGirl.create(:post_data) }
      @test_post = Post.new("blog/goodbye_love.mdown")
    end

    it 'assigns the name' do
      @test_post.name.should eq("blog/goodbye_love.mdown")
    end

    it 'assigns the section' do
      @test_post.section.should eq("blog")
    end

    it 'assigns the basename' do 
      @test_post.basename.should eq("goodbye_love.mdown")
    end
  end # end valid post name

  context 'invalid post name' do
     it "raises an exception with a post file that doesn't exist" do
       expect {@test_post = Post.new("fake/post.mdown")}.to raise_error(Starman::FileNotFoundError)
     end

     it "fails with a post missing a section" do
       expect {Post.new("fakepost.mdown")}.to raise_error(Starman::NameError)
     end
  end # end invalid post name

  context 'parsing valid post file' do
    before(:each) do 
      Post.stub(:exists?) {true}
      Post.any_instance.stub(:read_post_file) { FactoryGirl.create(:post_data) }

      @test_post = Post.new("perfectly/valid_post.mdown")
      @test_attributes = FactoryGirl.attributes_for(:post_data)
    end

    it 'has a date' do
      expect(@test_post.metadata["date"]).to eq(DateTime.strptime(@test_attributes[:date], '%m/%d/%Y'))
    end

    it 'has a summary' do
      expect(@test_post.metadata["summary"]).to eq(@test_attributes[:summary])
    end

    it 'has content' do
      expect(@test_post.content).to eq(@test_attributes[:content])
    end
     
    it 'has a title' do
      expect(@test_post.title).to eq(@test_attributes[:title])
    end

  end # end parsing valid post file

  context 'parsing invalid post file' do
    before(:each) do
      Post.stub(:exists?) {true}
    end

    it 'fails with missing date keyword' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :no_date_keyword)}
      expect{Post.new("fail/date_no_keyword.mdown")}.to raise_error(Starman::DateError)
    end

    it 'generates a default summary when the summary keyword is missing' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data,:no_summary_keyword)}
      @test_post = Post.new("default/summary_no_keyword.mdown")
      expect(@test_post.summary).to eq(@test_post.content[0..100])
    end

    it 'fails on keywords missing the delimiter' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :date_missing_colon)}
      expect{Post.new("fail/delimiter_missing.mdown")}.to raise_error(Starman::InvalidMetadata)
    end

    it 'generates default content when missing content' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :no_content)}
      expect(Post.new("default/content.mdown").content).to eq("This entry is empty. Please write something here!")
    end

    it 'generates default title when missing title' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :no_title)}
      expect(Post.new("default/default_title.mdown").title).to eq("Default Title")
    end

    it 'fails when it has a date keyword but no date' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :no_date)}
      expect{Post.new("fail/date_has_keyword.mdown")}.to raise_error(Starman::DateError)
    end

    it 'generates a default summary when it has a summary keyword but no summary' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data,:no_summary)}
      @test_post = Post.new("defaut/summary_has_keyword.mdown")
      expect(@test_post.summary).to eq(@test_post.content[0..100])
     end

    it 'generates a default summary and default content when it is missing both summary and content' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data,:no_summary, :no_content)}
      @test_post = Post.new("default/summary_and_content.mdown")
      expect(@test_post.content).to eq("This entry is empty. Please write something here!")
      expect(@test_post.summary).to eq(@test_post.content[0..100])
    end

    it 'fails with an improperly formatted date' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :bad_date)}
      expect{Post.new("fail/improper_date_format.mdown")}.to raise_error(Starman::DateError)
    end

    it 'ignores unrecognized metadata' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :extra_metadata)}
      @test_post = Post.new("ignore/excess_metadata.mdown")
      expect(@test_post.metadata[:in_sky]).to be_nil
      expect(@test_post.metadata[:mind]).to be_nil
    end

    it 'ignores leading and trailing whitespace' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :extra_whitespace)}
      @extra_whitespace= Post.new("ignore/extra_whitespace.mdown")

      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data)}
      @test_post = Post.new("normal/whitespace.mdown")
      
      expect(@extra_whitespace.metadata).to eq(@test_post.metadata)
      expect(@extra_whitespace.content).to eq(@test_post.content)
    end

    it 'fails when missing the metadata/content divider' do
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, :no_divider)}
      expect{Post.new("fail/missing_divider.mdown")}.to raise_error(Starman::FormattingError)
    end


  end # end invalid post file

end # end Post#initialize
