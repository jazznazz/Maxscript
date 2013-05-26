
	-- Custom bake elements v2
	--	25.05.13 , Hristo Dinev. A HUGE thanks to Neil Blevins - http://www.neilblevins.com/, and also to Chaos Group :)

	-- Usage:
	-- The script needs a version of "soulburn scripts" - http://www.neilblevins.com/cg_tools/soulburnscripts/soulburnscripts.htm
	-- for its object combining function, and also Vray - if you want to use Vray's specific bake elements, of course.
	
	-- Main purpose - baking testures to SEVERAL selected objects , not just one. 
	-- Tested on 3DS MAX 2013, but should run on older versions, too.
	-- No User interface for now, just open it in MAX's Script editor and hit Ctrl+E. 
	-- All the important variables are at the top and are relatively "human" readable. Read the comment after each variable for info.
	-- Change the "bakeElementCustom_elementName" variable to select a bake element.

bakeElementCustom_elementName = "Mray_AO"	-- Change the element you want to bake from here. Cases: "Mray_AO" , "Vray_DirtMap" , "Vray_EdgeSmooth" , "Scanline_Quick_BW_Mask"
bakePathFilename = "d:\\CustomMapBake.png" -- where the file is saved
bakeFileType = 		"d:\\CustomMapBake.png" -- same path, used just for the file extension
bakeTexSize = 512 -- texture size
bakePadding = 5 -- Padding
bakeChannel = 1 -- UV Channel
qualitySettingsString = "Production" -- Some Render Settings important for the bake . Cases: "Draft" or "Production"


-- RENDER ELEMENT SPECIFIC SETTINGS:
bakeDiffuseColor = color 255 255 255
bakeAOBrightColor = color 255 255 255
bakeAODarkColor = color 0 0 0
bakeMrayAOFallof = 1.0 --Float default: 1.0 -- float 
bakeMrayAOMaxDistance = 0.0 --Float, default: 0.0 -- float; Max_Dist 
bakeMrayAOMaxSamples = 128 --Integer, default: 16 -- integer
bakeMrayAOMaxSpread = 0.8 --Float, default: 0.8 -- float 

bakeVrayDirtSubdivs = 96 -- QUALITY , 96 is ok 
bakeVrayDirtRadius = 2	-- DISTANCE in MAX units
bakeVrayDirtDistribution = 0
bakeVrayDirtFalloff = 0.0
bakeVrayDirtBias = [0,0,0]
bakeVrayDirtInvertNormal = on	-- bake Edges or crevises.

bakeVrayEdgesTexWidthType = 0
bakeVrayEdgesTexThickness = 2

--rendererString = "*Default_Scanline_Renderer*" -- Cases : "*V_Ray_Adv*", "*V_Ray_RT*", "*mental_ray*" , "*Default_Scanline_Renderer*"
--bakeElementCustom = Ambient_Occlusion () -- Cases: Ambient_Occlusion () , VRayDiffuseFilterMap () , VRayBumpNormalsMap () , DiffuseFilterMap ()

-- CODE:

fn setRenderer rendererString = 
(
	for a=1 to RendererClass.classes.count do 
	(
		if (matchPattern (RendererClass.classes[a] as string) pattern:rendererString) 
		then 
			(renderers.current = RendererClass.classes[a] ()
			
			print (rendererString + " set for renderer")
			)
	)
)

fn setVraySettings qualitySettingsString = -- Cases : "Production", "Draft"
(
--show (vr=renderers.current) --vray
	case of
	(
		(qualitySettingsString == "Draft") :
			(	
			renderers.current.imageSampler_type =2 --Adaptive Subdivision
			renderers.current.filter_on = false --on default, off draft
			renderers.current.filter_size =1.0 --1.5 default, 1.0 draft
			renderers.current.gi_on = false --off
			renderers.current.options_overrideMtl_on = false
			renderers.current.output_force32bit_3dsmax_vfb = false
			)
			
		(qualitySettingsString == "Production") :
			(
			renderers.current.imageSampler_type =1 --Adaptive DMC
			renderers.current.filter_on = true --on default, off draft
			renderers.current.filter_size =1.5 --1.5 default, 1.0 draft
			renderers.current.gi_on = false --off
			renderers.current.options_overrideMtl_on = false
			renderers.current.output_force32bit_3dsmax_vfb = false
			)
	)
)

fn setMraySettings qualitySettingsString = -- Cases : "Production", "Draft"
(
--show (vr=renderers.current) --mray
	case of
	(
		(qualitySettingsString == "Draft") :
			(	
			renderers.current.filter = 0 -- 0=Box
			renderers.current.MinimumSamples = -1 -- -1 = 1/4 : default
			renderers.current.MaximumSamples = -0 -- 1 = 4 : default
			renderers.current.BoxFilterWidth = 1
			renderers.current.BoxFilterHeight = 1
			)
			
		(qualitySettingsString == "Production") :
			(	
			renderers.current.filter = 0 -- 0=Box
			renderers.current.MinimumSamples = 0 -- -1 = 1/4 : default
			renderers.current.MaximumSamples = 2 -- 1 = 4 : default
			renderers.current.BoxFilterWidth = 1.5
			renderers.current.BoxFilterHeight = 1.5
			)
	)
)

--BAKE JOB:
(
	--OBJECT SELECT AND HIDE
	
	selectionBuffer = selection as array -- "as array" - VERY IMPORTANT! othrewise the variable holds a "live" selection
	maxOps.CloneNodes selectionBuffer cloneType:#copy newNodes:&objectsForAttachAndBake

	hide selectionBuffer
	select objectsForAttachAndBake
	attachSelectedObjectsDefaults() -- Stolen from Neil Blevin's "attach objects" - needs "SoulBurn Scripts" to run
	
	obj = selection[1] 
	obj.removeAllBakeElements()
	
-- RENDER ELEMENT SPECIFIC PROPERTIES:
	case of
	(
	(bakeElementCustom_elementName == "Mray_AO"): 
		(
		setRenderer "*mental_ray*"
		--setMraySettings qualitySettingsString
		bakeElementCustom = Ambient_Occlusion ()
		obj.material = StandardMaterial ()
			
		bakeElementCustom.bright = bakeAOBrightColor
		bakeElementCustom.dark = bakeAODarkColor
		bakeElementCustom.falloff  = bakeMrayAOFallof
		bakeElementCustom.filterOn  = true --BooleanClass default: true -- boolean; FilteringOn 
		bakeElementCustom.maxDistance  = bakeMrayAOMaxDistance
		bakeElementCustom.samples = bakeMrayAOMaxSamples
		bakeElementCustom.spread = bakeMrayAOMaxSpread 
		)
		
	(bakeElementCustom_elementName == "Vray_DirtMap"):
		(
		setRenderer "*V_Ray_Adv*"
		setVraySettings qualitySettingsString
		bakeElementCustom = VRayDiffuseFilterMap ()
		--SET MATERIAL	
		obj.material = VRayMtl ()
		obj.material.texmap_diffuse = VRayDirt ()
		obj.material.texmap_diffuse.subdivs = bakeVrayDirtSubdivs
		obj.material.texmap_diffuse.radius = bakeVrayDirtRadius
		obj.material.texmap_diffuse.Distribution = bakeVrayDirtDistribution
		obj.material.texmap_diffuse.falloff = bakeVrayDirtFalloff
		obj.material.texmap_diffuse.bias = bakeVrayDirtBias
		obj.material.texmap_diffuse.invert_normal = bakeVrayDirtInvertNormal
		obj.material.texmap_diffuse.occluded_color = bakeAODarkColor
		obj.material.texmap_diffuse.unoccluded_color = bakeAOBrightColor
		)
		
	(bakeElementCustom_elementName == "Vray_EdgeSmooth"):
		(
		setRenderer "*V_Ray_Adv*"
		setVraySettings qualitySettingsString
		bakeElementCustom = VRayBumpNormalsMap ()
		--SET MATERIAL		
		obj.material = VRayMtl ()
		obj.material.texmap_bump = VRayEdgesTex ()
		obj.material.texmap_bump.widthType = bakeVrayEdgesTexWidthType
		obj.material.texmap_bump.thickness = bakeVrayEdgesTexThickness
		)
		
	(bakeElementCustom_elementName == "Scanline_Quick_BW_Mask"):
		(
		setRenderer "*Default_Scanline_Renderer*"
		obj.material = StandardMaterial ()
		obj.material.diffuse = bakeDiffuseColor
		bakeElementCustom = DiffuseMap ()
		)
		
	)
	
	--START BAKE
	
	bakeElementCustom.fileName = bakePathFilename 
	bakeElementCustom.fileType = bakeFileType 
	bakeElementCustom.outputSzX = BakeTexSize
	bakeElementCustom.outputSzY = BakeTexSize
	bakeElementCustom.enabled = true
	bakeElementCustom.autoSzOn = false

	bake = obj.INodeBakeProperties
	bake.bakeChannel = bakeChannel
	bake.nDilations     =	bakePadding
	bake.bakeEnabled = true;

	bake.addBakeElement bakeElementCustom

	renderWindow = (render rendertype:#bakeSelected outputwidth:BakeTexSize outputheight:BakeTexSize vfb:true progressBar:true)
	unDisplay renderWindow
	
	--OBJECT SELECT AND UNHIDE
	delete $
	for a in selectionBuffer do (unhide a )
	select selectionBuffer
	
	--REMOVE TRACES
	bake.removeBakeElement bakeElementCustom --remove the custom element bake entry
	
	display (openBitMap bakePathFilename)
)
