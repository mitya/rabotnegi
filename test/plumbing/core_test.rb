require 'test_helper'

unit_test "Object ext" do
  class TPerson
    attr_accessor :fname, :lname
  end
  
  test "class" do
    assert_equal 123.class, 123._class
  end
  
  test "is?" do
    assert 132.is?(String, NilClass, Fixnum)
    assert !132.is?(String, NilClass, Symbol)
  end
  
  test "send_chain" do
    assert_equal "h", "hello".send_chain("first")
    assert_equal 104, "hello".send_chain("first.ord")
    assert_equal "104", "hello".send_chain("first.ord.to_s")
  end
  
  test "assign_attributes" do
    person = TPerson.new
    person.assign_attributes(fname: "Joe", lname: "Smith", age: 25)
    assert_equal "Joe", person.fname
    assert_equal "Smith", person.lname
    assert_not_respond_to person, :age
  end

  test "assign_attributes!" do
    assert_raise NoMethodError do
      TPerson.new.assign_attributes!(fname: "Joe", lname: "Smith", age: 25)
    end
  end
end

unit_test "File ext" do
  test "write" do
    assert_respond_to File, :write
  end
end

unit_test "Hash ext" do
  test "append_string" do
    hash = {aa: "AA"}

    hash.append_string(:aa, "and AA")
    assert_equal "AA and AA", hash[:aa]
    
    hash.append_string(:bb, "and BB")
    assert_equal "and BB", hash[:bb]  
  end

  test "prepend_string" do
    hash = {aa: "AA"}

    hash.prepend_string(:aa, "and AA")
    assert_equal "and AA AA", hash[:aa]
    
    hash.prepend_string(:bb, "and BB")
    assert_equal "and BB", hash[:bb]  
  end
end

unit_test "JSON conversions" do
  test "Time" do
    assert_equal "\"2012-01-01T12:00:00Z\"", "2012-01-01T12:00:00Z".to_time.to_json
    assert_equal "2012-01-01T12:00:00Z", "2012-01-01T12:00:00Z".to_time.as_json
  end
  
  test "BSON::ObjectId" do
    id = BSON::ObjectId.new
    assert_not_equal id.to_json, id.as_json
  end
end

unit_test "Module ext" do
  class TProcess
    attr_accessor :status
    def_state_predicates 'status', :started, :failed, :done
  end    

  test "def_state_predicates" do    
    assert_equal :status, TProcess._state_attr
    assert_equal [:started, :failed, :done], TProcess._states
    
    process = TProcess.new
    assert_respond_to process, :started?
    assert_respond_to process, :failed?
    assert_respond_to process, :done?
    
    process.status = "failed"
    assert process.failed?
    assert !process.done?

    process.status = :done
    assert !process.failed?
    assert process.done?
  end
end
