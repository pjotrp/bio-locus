require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BioLocus with Moneta" do
  store = BioLocus::MonetaMapper.new(:LocalMemCache,'test.db')
  store['test'] = 'yes'
  store['test2'] = 'no'
  a = store['test']
  store['test'].should == 'yes'
  store['test2'].should  == 'no'
  store.close
  File.unlink('test.db')
end
