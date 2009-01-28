require File.dirname(__FILE__) + '/../spec_helper'

class QueriesHelperWrapper
  include QueriesHelper
  include ActionView::Helpers::TextHelper
  include IssuesHelper
end


describe QueriesHelper,"#format_questions with no questions" do
  it 'should return an empty string' do
    QueriesHelperWrapper.new.format_questions([]).should eql('')
  end
end

describe QueriesHelper,"#format_questions with one question" do
  before(:each) do
    @content = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
    @journal = mock_model(Journal, :notes => @content)
    @issue = mock_model(Issue, :closed? => false, :tracker => mock_model(Tracker, :name => 'Bug'))
    @author = mock_model(User, :name => "Author User")
    @assignee = mock_model(User, :name => "Assignee")
    @question = mock_model(Question, :journal => @journal, :issue => @issue, :author => @author, :assigned_to => @assignee)
    @questions = [@question]
    @helper = QueriesHelperWrapper.new
    @helper.stub!(:link_to).and_return('<a href="/test">Test</a>')
  end
  
  it 'should not be blank' do
    @helper.format_questions(@questions).should_not be_blank
  end
  
  it 'should show the first 120 characters of the question in the summary' do
    question_content = @helper.format_questions(@questions)
    question_content.should have_tag("span.question_summary", /This is a journal note/)
    question_content.should_not have_tag("span.question_summary", /really work/)
  end
  
  it 'should have ellipses if when over 120 characters of content' do
    question_content = @helper.format_questions(@questions)
    question_content.should have_tag("span.question_summary", /\.\.\./)
   end

  it 'should not have ellipses when there are under 120 characters of content' do
    content = 'Short question'
    journal = mock_model(Journal, :notes => content)
    question = mock_model(Question, :journal => journal, :issue => @issue, :author => @author, :assigned_to => @assignee)
    questions = [question]

    question_content = @helper.format_questions(questions)
    question_content.should_not have_tag("span.question_summary", /\.\.\./)
  end

end

describe Question,"#format_questions with multiple questions" do
  before(:each) do
    @content_one = 'This is a journal note that is supposed to have the question content in it but only up the 120th character, but does it really work?'
    @journal_one = mock_model(Journal, :notes => @content_one)
    @content_two = 'Another journal with a unique content that is well over 120 characters but it will be ok becasue it is truncated soon.  Maybe.'
    @journal_two = mock_model(Journal, :notes => @content_two)
    @issue = mock_model(Issue, :closed? => false, :tracker => mock_model(Tracker, :name => 'Bug'))
    @author = mock_model(User, :name => "Author User")
    @assignee = mock_model(User, :name => "Assignee")
    
    @question = mock_model(Question, :journal => @journal_one, :issue => @issue, :author => @author, :assigned_to => @author)
    @question_two = mock_model(Question, :journal => @journal_two, :issue => @issue, :author => @author, :assigned_to => @author)
    @questions = [@question, @question_two]
    @helper = QueriesHelperWrapper.new
    @helper.stub!(:link_to).and_return('<a href="/test">Test</a>')
  end
  
  it 'should not be empty' do
    @helper.format_questions(@questions).should_not be_empty
  end
  
  it 'should show the first 120 characters of each question in the summary' do
    question_content = @helper.format_questions(@questions)
    question_content.should have_tag("span.question_summary", /This is a journal note/)
    question_content.should_not have_tag("span.question_summary", /really work/)

    question_content.should have_tag("span.question_summary", /unique/)
    question_content.should_not have_tag("span.question_summary", /maybe/)
  end
end

