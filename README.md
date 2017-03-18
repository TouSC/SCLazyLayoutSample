<h1>How to Use</h1>

1. 在AppDelegate的didFinishLaunchingWithOptions中添加

		[SCLazyLayout setEnvironment:SCLazyEviromentSandbox];
		
2. 将需要布局的View继承自SCLazyView
3. 给该View的实例添加uuid并调用布局方法（uuid是该实例在项目中的唯一标示）
		
	    view.uuid = @"TestView";
	    [view lazyLayout];
	    
4. 给该View的所有SubView设置不重复的tag

<h3>这样在沙盒模式（SCLazyEviromentSandbox）下，就可以在APP内通过长按View来激活布局模式。<br><br>
如果切换到生产模式（SCLazyEviromentLive），只需要将Document路径下的SCLazyLayoutFile文件夹拖入到项目中（注意勾选Create folder references）<h3>
