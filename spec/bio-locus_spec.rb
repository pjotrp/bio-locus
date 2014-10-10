require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BioLocus with Moneta" do
  fn = 'biolocus_moneta_localmemcache.db'
  store = BioLocus::MonetaMapper.new(:LocalMemCache,fn)
  store['test'] = 'yes'
  store['test2'] = 'no'
  a = store['test']
  store['test'].should == 'yes'
  store['test2'].should  == 'no'
  store.close
  File.unlink(fn)
end

describe "BioLocus with TokyoCabinet" do
  fn = 'biolocus_tokyocabinet.db'
  store = BioLocus::TokyoCabinetMapper.new(fn)
  store['test'] = 'yes'
  store['test2'] = 'no'
  a = store['test']
  store['test'].should == 'yes'
  store['test2'].should  == 'no'
  store.close
  File.unlink(fn)
end
