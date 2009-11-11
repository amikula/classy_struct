require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ClassyStruct do
  before :each do
    @foo_struct = ClassyStruct.new
    @bar_struct = ClassyStruct.new
  end

  describe :new do
    it "returns something that is not a ClassyStruct" do
      ClassyStruct.new.should_not be_a(ClassyStruct)
    end

    it "returns something that inherits from ClassyStruct" do
      ClassyStruct.new.ancestors.should include(ClassyStruct::ClassyStructClass)
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

  describe ClassyStruct::ClassyStructClass do
    describe :child_node do
      it 'creates a child node whose class is a ClassyStructClass' do
        @foo_struct.node_class(:bar).ancestors.should include(ClassyStruct::ClassyStructClass)
      end

      it 'creates child nodes whose class is the same regardless of the instance' do
        klazz1 = @foo_struct.node_class(:bar)
        klazz2 = @foo_struct.node_class(:bar)

        klazz1.should == klazz2
      end

      it 'creates child nodes whose class is different for different ClassyStruct instances' do
        klazz1 = @foo_struct.node_class(:bar)
        klazz2 = @bar_struct.node_class(:bar)

        klazz1.should_not == klazz2
      end
    end

    describe :initialize do
      it 'initializes attributes with a hash provided' do
        o = @foo_struct.new(:foo => :bar, 'baz' => :xyzzy)

        o.foo.should == :bar
        o.baz.should == :xyzzy
      end

      it 'initializes sub-hashes by creating new ClassyStruct child nodes' do
        o = @foo_struct.new(:foo => :bar, 'baz' => {:xyzzy => 'something', 'thud' => 'splat'})

        o.foo.should == :bar
        o.baz.should_not be_a(Hash)
        o.baz.xyzzy.should == 'something'
        o.baz.thud.should == 'splat'
      end

      it 'creates persistent ClassyStructClass objects for child nodes' do
        o = @foo_struct.new(:foo => :bar, 'baz' => {:xyzzy => 'something', 'thud' => 'splat'})
        p = @foo_struct.new(:foo => :bar, 'baz' => {:xyzzy => 'something', 'thud' => 'splat'})

        o.class.should     == p.class
        o.baz.class.should == p.baz.class
      end
    end

    describe :new_child do
      it 'returns a new child node whose class is the node_class for the provided key' do
        o = @foo_struct.new

        o.new_child(:foo).class.should == @foo_struct.node_class(:foo)
      end

      it 'assigns the attribute provided with the new child node' do
        o = @foo_struct.new

        o.new_child(:foo).should == o.foo
      end
    end
  end
end
