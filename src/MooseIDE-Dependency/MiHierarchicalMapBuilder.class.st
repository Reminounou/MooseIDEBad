"
I am a builder of a hierarchical map using HierarchicalMapModel.

Nodes are colored according to properties.

I am responsible for :
- creating the nodes for each entity
- display the nodes on a canvas
- color the nodes according to their property
"
Class {
	#name : #MiHierarchicalMapBuilder,
	#superclass : #HSimpleVisualizationBuilder,
	#instVars : [
		'mapModel'
	],
	#category : #'MooseIDE-Dependency-HierarchicalMap'
}

{ #category : #'public - hooks' }
MiHierarchicalMapBuilder >> borderFor: node [

	| border |
	border := RSBorder new
		          width: 2;
		          capSquare;
		          joinMiter;
		          color: Smalltalk ui theme borderColor translucent;
		          yourself.
	node hasChildren ifTrue: [ 
		^ border
			  color: Smalltalk ui theme textColor;
			  dashArray: #( 1 5 );
			  yourself ].
	^ border
]

{ #category : #building }
MiHierarchicalMapBuilder >> build [

	rootNode := HNode new
		            addAll:
			            (self elements collect: [ :e | 
					             self buildNodeFromEntity: e ]);
		            yourself.
	self buildLegend.
	super build
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> buildCompositeEmptyNodeIn: shape [
	| node box rect |
	node := shape model.
	shape addAll: (self nodeStyler labelAndIconFor: node).
	rect := shape children encompassingRectangle.
	box := RSBox new 
		model: node;
		position: rect floatCenter;
		extent: rect extent + 10;
		cornerRadius: self fullCornerRadius;
		color: (self colorFor: node);
		border: (self borderFor: node);
		yourself.
	
	box when: RSMouseDoubleClick do: [ :e | node expandCollapse  ] .
	shape add: box.
	box pushBack.
	shape schildren: #().
	
	shape 
		propertyAt: #background put: box;
		adjustToChildren
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> buildCompositeFullNodeIn: shape [
	| childrenShapes node titleGroup title titleBox children 
	boxChildren titleRadius boxChildrenRadius list |
	node := shape model.
	titleGroup := self nodeStyler labelAndIconFor: node.
	titleBox := RSBox new
		extent: titleGroup extent + 10;
		color: ((self colorFor: node) alpha: 0.7);
		position: titleGroup position;
		yourself.
	title := RSComposite new
		add: titleBox; 
		addAll: titleGroup;
		adjustToChildren;
		yourself.
	title when: RSMouseDoubleClick do: [ :e | node expandCollapse  ] .
	shape propertyAt: #background put: titleBox.
	childrenShapes := self childrenFor: node.
	self layoutOn: childrenShapes parent: node.
	
	shape schildren: childrenShapes.
	childrenShapes do: [ :child | child sparent: shape ].
	children := childrenShapes asShape
		padding: 6.
	childrenShapes do: [ :child | child model position: child position ].
	title width < children width
		ifTrue: [ titleBox width: children width. title adjustToChildren ]
		ifFalse: [ children width: title width ].
	boxChildren := self boxChildrenFor: node.
	titleRadius := self topCornerRadius.
	boxChildrenRadius := self bottomCornerRadius.
	list := { title. children }.
	self nodeStyler position = #below ifTrue: [ 
		titleRadius := self bottomCornerRadius.
		boxChildrenRadius := self topCornerRadius.
		list := { children. title }.
		 ].
	RSVerticalLineLayout new
		gapSize: 0;
		on: list.
	titleBox cornerRadius: titleRadius.
	boxChildren
		cornerRadius: boxChildrenRadius;
		fromRectangle: children encompassingRectangle.
	
	shape add: title; add: boxChildren; add: children.
	shape adjustToChildren.
	
]

{ #category : #building }
MiHierarchicalMapBuilder >> buildLegend [

	| legend |
	legend := RSLegend new
		          container: self canvas;
		          title: 'Dynamic tags';
		          onDemand: 'Legend';
		          legendDo: [ :l | 
			          l
				          border: RSBorder new;
				          color: Color white;
				          padding: 10 ];
		          yourself.
	mapModel dynamicTags do: [ :dt | 
		legend
			text: dt name
			withBoxColor: (self mapModel colorForDynamicTag: dt) ].
	legend build
]

{ #category : #building }
MiHierarchicalMapBuilder >> buildNodeFromEntity: anEntity [

	^ HNode new
		  name:
			  (String streamContents: [ :s | anEntity displayStringOn: s ]);
		  rawModel: anEntity;
		  addAll: ((self mapModel childrenFor: anEntity)
				   collect: [ :e | 
					   anEntity == e ifFalse: [ self buildNodeFromEntity: e ] ]
				   thenSelect: [ :e | e isNotNil ]);
		  collapse;
		  yourself
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> childrenBlock [

	^ mapModel childrenBlock
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> colorFor: node [

	^ mapModel colorFor: node rawModel
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> cornerRadius [

	^ 3
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> elements [

	^ mapModel entities
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> mapModel [

	^ mapModel
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> mapModel: anObject [

	mapModel := anObject
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> shapeFor: node [
	| shape |
	shape := RSComposite new
		model: node;
		announcer: self nodeAnnouncer;
		yourself.
	
	(node isExpanded and: [node hasChildren]) 
		ifTrue: [ self buildCompositeFullNodeIn: shape ]
		ifFalse: [ self buildCompositeEmptyNodeIn: shape ].

	node 
		removeInteractionIfPresent: self class;
		when: HNodeAddedEvent do: [ :evt | self rebuildRootShape: shape ];
		when: HCollapseEvent do: [ :evt |	self rebuildShape: shape ];
		when: HExpandEvent do: [ :evt | self rebuildRootShape: shape. self zoomOutFor: shape ];
		when: HNodeChangedEvent do: [ :evt | self rebuildShape: shape ].
	shapes add: shape.
	^ shape 
	
]

{ #category : #accessing }
MiHierarchicalMapBuilder >> zoomOutFor: aShape [

	| camera |
	camera := self canvas camera.
	camera scale: 1.0
]