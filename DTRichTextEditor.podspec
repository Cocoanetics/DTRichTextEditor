Pod::Spec.new do |spec|
  spec.name         = 'DTCoreText'
  spec.version      = '1.4.0'
  spec.platform     = :ios, '4.3'
  spec.license      = 'BSD'
  spec.source       = { :git => 'git@git.cocoanetics.com:parts/dtrichtexteditor.git', :tag => spec.version.to_s }
  spec.source_files = 'Core/Source/*.{h,m,c}'
  spec.dependency 'DTCoreText', '~>1.4'
  spec.dependency 'DTWebArchive', '~>1.0'
  spec.dependency 'DTLoupeView', '~>1.4'
  spec.frameworks   = 'AssetsLibrary'
  spec.requires_arc = true
  spec.homepage     = 'http://www.cocoanetics.com/parts/dtrichtexteditor/'
  spec.summary      = 'A framework to implement Rich Text Editing on iOS.'
  spec.author       = { 'Oliver Drobnik' => 'oliver@cocoanetics.com' }
end
