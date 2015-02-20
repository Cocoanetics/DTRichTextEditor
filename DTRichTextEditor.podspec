Pod::Spec.new do |spec|
  spec.name         = 'DTRichTextEditor'
  spec.version      = '1.6.9'
  spec.platform     = :ios, '6.0'
  spec.license      = 'BSD'
  spec.source       = { :git => 'git@git.cocoanetics.com:parts/dtrichtexteditor.git', :tag => spec.version.to_s }
  spec.source_files = 'Core/Source/*.{h,m,c}', 'Core/*.h'
  spec.prefix_header_contents = '#import "DTLog.h"'
  spec.dependency 'DTCoreText', '~>1.6.15'
  spec.dependency 'DTWebArchive', '~>0.0.1'
  spec.dependency 'DTLoupe', '~>1.5.5'
  spec.dependency 'DTFoundation', '~>1.7.5'
  spec.frameworks   = 'AssetsLibrary'
  spec.requires_arc = true
  spec.homepage     = 'http://www.cocoanetics.com/parts/dtrichtexteditor/'
  spec.summary      = 'A framework to implement Rich Text Editing on iOS.'
  spec.author       = { 'Oliver Drobnik' => 'oliver@cocoanetics.com' }
end
