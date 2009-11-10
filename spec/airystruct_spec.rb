require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Airystruct do
  before :each do
    @foo_struct = Airystruct.new
    @bar_struct = Airystruct.new
  end

  describe :new do
    it "returns something that is not an Airystruct" do
      Airystruct.new.should_not be_an(Airystruct)
    end

    it "returns something that inherits from AirystructClass" do
      Airystruct.new.ancestors.should include(Airystruct::AirystructClass)
    end
  end

  describe :method_missing do
    it 'assigns and returns values' do
      o = @foo_struct.new

      o.bar = :baz
      o.bar.should == :baz
    end

    it 'adds methods to the base class' do
      o = @foo_struct.new

      o.bar = :baz

      o.methods.should include('bar')
      o.class.instance_methods.should include('bar')

      p = @foo_struct.new
      p.methods.should include('bar')

      p.should_not_receive(:method_missing)
      p.bar
    end

    it 'does not add methods to other class instances' do
      o = @foo_struct.new
      o.bar = :baz

      @foo_struct.instance_methods.should include('bar')
      @bar_struct.instance_methods.should_not include('bar')
    end
  end

  describe :initialize do
    it 'initializes attributes with a hash provided' do
      o = @foo_struct.new(:foo => :bar, 'baz' => :xyzzy)

      o.foo.should == :bar
      o.baz.should == :xyzzy
    end
  end
end
