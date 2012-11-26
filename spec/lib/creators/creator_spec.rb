require 'spec_helper'

class Log
  def self.error(exception)

  end
end

describe Creators::Base do

  class FakeModel
    attr_reader :an_attribute, :another_attribute

    def initialize(attribute = nil, another = nil)
      @an_attribute = attribute
      @another_attribute = another
    end

    def self.build
      FakeModel.new
    end

    def attributes=(attributes)
    end

    def save
    end

    def errors
      nil
    end
  end

  class AnotherFakeModel
  end

  class FakeModelCreator < Creators::Base
  end

  class AnotherFakeModelCreator < Creators::Base
    model 'FakeModel'
  end

  subject { FakeModelCreator.new }

  describe 'self.model' do

    let(:another_creator) { AnotherFakeModelCreator.new }

    it 'should override the target model of the Creator (which is implied from the Creator name)' do
      another_creator.klass.should == FakeModel
      another_creator.klass.should_not == AnotherFakeModel
    end

  end

  describe :save do

    context 'params are invalid' do
      it 'should return false when raw params are invalid' do
        subject.save.should be_false
      end
    end

    context 'params are valid' do
      before (:all) do
        subject.stub(:before_build => true)
        FakeModel.any_instance.stub(:save => true)
      end

      it 'should return true' do
        subject.save.should be_true
      end

      it 'should have the new instance returned by the model method' do
        subject.model.class.should == FakeModel
      end

      it 'should have an aliased method for the model named after the the creator name' do
        subject.send(FakeModel.to_s.underscore).should == subject.model
      end
    end

    context 'update existing model' do

      let(:changed_attribute)   { 1 }
      let(:changing_attribute)  { 2 }
      let(:static_attribute)    { 3 }
      let(:old_model)           { FakeModel.new(changed_attribute, static_attribute) }
      subject { FakeModelCreator.new({:an_attribute => changing_attribute}, old_model)}

      before (:each) do
        old_model.stub(:validate_params => true)
        subject.save
      end

      it 'should not create a new model after save' do
        subject.model.should == old_model
      end

      it 'should change only attributes that were passed in the raw params' do
        subject.model.an_attribute == changing_attribute
        subject.model.another_attribute == static_attribute
      end
    end
  end

  describe :errors do
    def error_before_build
      def subject.before_build
        error(:field, "text")
      end
    end

    def error_during_refine_params
      def subject.refine_params
        error(:field, "text")
      end
    end

    def error_after_build
      def subject.after_build
        error(:field, "text")
      end
    end

    it "should return a hash with standard errors" do
      subject.errors.should == {}
    end

    it "should fill in an error if an error occurs before build" do
      error_before_build
      subject.save.should be_false
      subject.errors.should == {:field => "text"}
    end

    it "should fill in an error if an error during refinment " do
      error_during_refine_params
      subject.save.should be_false
      subject.errors.should == {:field => "text"}
    end

    it "should fill in an error if an error after build " do
      error_after_build
      subject.save.should be_false
      subject.errors.should == {:field => "text"}
    end

    it "should return a merged error hash of both the model.errors and validation errors" do
      error_after_build
      FakeModel.any_instance.stub(:errors => {:field2 => "txet"})
      subject.save.should be_false
      subject.errors.should == {:field => "text", :field2 => "txet"}
    end

    it "should return only model.errors if no validation errors" do
      FakeModel.any_instance.stub(:errors => {:field2 => "txet"})
      subject.save.should be_false
      subject.errors.should == {:field2 => "txet"}
    end

    it "should log validation errors that happen" do
      error_before_build
      Log.should_receive(:error)
      subject.save
    end
  end

end