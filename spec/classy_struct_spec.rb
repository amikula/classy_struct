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

    it 'assigns a method mapper if a block is given' do
      prok = Proc.new{'proc_out'}

      ClassyStruct.new(&prok).method_mapper.should == prok
    end

    it 'maintains unique method mappers per instance' do
      prok1 = Proc.new{'proc_out1'}
      prok2 = Proc.new{'proc_out2'}

      klass1 = ClassyStruct.new(&prok1)
      klass2 = ClassyStruct.new(&prok2)

      klass1.method_mapper.should == prok1
      klass2.method_mapper.should == prok2
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
        klass1 = @foo_struct.node_class(:bar)
        klass2 = @foo_struct.node_class(:bar)

        klass1.should == klass2
      end

      it 'creates child nodes whose class is different for different ClassyStruct instances' do
        klass1 = @foo_struct.node_class(:bar)
        klass2 = @bar_struct.node_class(:bar)

        klass1.should_not == klass2
      end

      it 'passes the method mapper to the child node class' do
        prok = Proc.new{|m| m.downcase}

        the_struct = ClassyStruct.new(&prok)
        the_struct.node_class(:bar).method_mapper.should == prok
      end
    end

    describe :initialize do
      it 'initializes attributes with a hash provided' do
        o = @foo_struct.new(:foo => :bar, 'baz' => :xyzzy)

        o.foo.should == :bar
        o.baz.should == :xyzzy
      end

      it 'maps hash keys with the method mapper if provided' do
        the_struct = ClassyStruct.new{|m| m.tr('bf', 'fb')}

        o = the_struct.new(:foo => :bar, 'baz' => :xyzzy)

        o.boo.should == :bar
        o.faz.should == :xyzzy
      end

      it 'maps hash keys on nested hashes' do
        the_struct = ClassyStruct.new{|m| m.tr('bf', 'fb')}

        o = the_struct.new(:foo => {:bar => :xyzzy})

        o.boo.far.should == :xyzzy
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

      it 'converts arrays' do
        o = @foo_struct.new(:foo => [{:bar => :baz}, {:bar => :xyzzy}, {:bar => :thud}])

        o.foo.collect{|f| f.bar}.should == [:baz, :xyzzy, :thud]
      end

      it 'uses the same class for each converted hash member of arrays' do
        o = @foo_struct.new(:foo => [{:bar => :baz}, {:bar => :xyzzy}, {:bar => :thud}])

        o.foo[0].class.should == o.foo[1].class
        o.foo[0].class.should == o.foo[2].class
      end

      it 'creates new classes that do not match the object class when mapping arrays' do
        o = @foo_struct.new(:foo => [{:bar => :baz}])

        o.class.should_not == o.foo.first.class
      end

      it 'uses the method mapper for hash members of arrays' do
        mstruct = ClassyStruct.new{|k| k.downcase}

        o = mstruct.new('Bar' => [{'Baz' => :xyzzy}])

        o.bar.should be_an(Array)
        o.bar.length.should == 1
        o.bar.first.baz.should == :xyzzy
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
