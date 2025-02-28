"
A model for the MiDSMBrowser, contains the entities to display, computes the dependencies and the colors to show the cells of the DSM matrix
"
Class {
	#name : #MiDependencyStructuralMatrixBrowserModel,
	#superclass : #MiAbstractModel,
	#instVars : [
		'graph',
		'nodeColors',
		'orderedNodesX',
		'orderedNodesY',
		'dependencyDictionary',
		'selectedEntities'
	],
	#category : #'MooseIDE-Dependency-DSM'
}

{ #category : #buildGraph }
MiDependencyStructuralMatrixBrowserModel >> buildGraph: aCollection [

	self newGraph.
	self buildGraphNodes: aCollection.

	self initializeDependencies.

	self buildGraphEdges.
	self computeSCCs
]

{ #category : #buildGraph }
MiDependencyStructuralMatrixBrowserModel >> buildGraphEdges [
	"We choose to say that there is a relation from line to column if line depends on column"
	| entities |
	entities := self entities.
	
	graph
			edges: entities
			from: #yourself
			toAll: [ :sourceEntity | 
				entities select: [ :targetEntity | 
					(dependencyDictionary at:(sourceEntity -> targetEntity ) ) isNotEmpty 
				]
			]
]

{ #category : #buildGraph }
MiDependencyStructuralMatrixBrowserModel >> buildGraphNodes: aCollection [

	graph nodes: (aCollection "asMooseGroup" select: [ :e | 
			 e usesFamixTrait: TEntityMetaLevelDependency ]).
	"nodeDictionary := Dictionary new: aCollection size.
	graph nodes do: [ :node | nodeDictionary at: node model put: node ]"
]

{ #category : #testing }
MiDependencyStructuralMatrixBrowserModel >> canFollowEntity: anObject [

	^ anObject isCollection and: [ 
		  anObject allSatisfy: [ :a | 
			  a usesFamixTrait: TEntityMetaLevelDependency ] ].
]

{ #category : #api }
MiDependencyStructuralMatrixBrowserModel >> colorForTuple: tuple [

	(self isDiagonal: tuple) ifTrue: [ ^self diagonalColor ].
	(self isDependency: tuple) ifFalse: [ ^self defaultColor ].

	(self isCycle: tuple) ifTrue: [ ^ self sccColor ].
	^ self dependencyColor
]

{ #category : #buildGraph }
MiDependencyStructuralMatrixBrowserModel >> computeSCCs [
	"run tarjan"
	graph run
]

{ #category : #settings }
MiDependencyStructuralMatrixBrowserModel >> defaultColor [

	^ nodeColors at: #defaultCell
]

{ #category : #settings }
MiDependencyStructuralMatrixBrowserModel >> dependencyColor [

	^ nodeColors at: #dependency
]

{ #category : #settings }
MiDependencyStructuralMatrixBrowserModel >> diagonalColor [

	^nodeColors at: #diagonalCell
]

{ #category : #api }
MiDependencyStructuralMatrixBrowserModel >> displayValueForNode: aNode [
	^aNode model name
]

{ #category : #api }
MiDependencyStructuralMatrixBrowserModel >> displayValueForTuple: tuple [
	^(self displayValueForNode: tuple key), ' -> ' , (self displayValueForNode: tuple value)
]

{ #category : #accessing }
MiDependencyStructuralMatrixBrowserModel >> entities [

	^ graph nodes collect: #model
]

{ #category : #testing }
MiDependencyStructuralMatrixBrowserModel >> entity: aCandidate belongsTo: anEntity [
	"test whether aDependentEntity can be scoped up to anEntity"

	^(aCandidate atScope: anEntity class) includes: anEntity
]

{ #category : #actions }
MiDependencyStructuralMatrixBrowserModel >> followEntity: aCollection [

	self selectedEntities: aCollection.

	self buildGraph: aCollection.

	orderedNodesX := self orderNodes: graph nodes.
	orderedNodesY := orderedNodesX.

	browser buildDSM
]

{ #category : #actions }
MiDependencyStructuralMatrixBrowserModel >> getDependenciesFrom: entityX to: entityY [
	"generic algorithm to get all dependencies from entityX to entityY at the scope of entityY"

	^entityX queryAllOutgoingForDSM select: [ :dependency || opposites |
		dependency isAssociation ifTrue: [
			"Association so need to get the target because DSM is done between entities"
			opposites := dependency target.
			opposites isCollection
			ifTrue: [ opposites anySatisfy: [ :each |
					self entity: each belongsTo: entityY ]
			]
			ifFalse: [ self entity: opposites belongsTo: entityY ]
			]
		ifFalse: [ 
			"case of declaredType"
			dependency isStub
				ifTrue: [ false ]
				ifFalse: [ self entity: dependency belongsTo: entityY ]
			 ]
	]
]

{ #category : #api }
MiDependencyStructuralMatrixBrowserModel >> getTupleDependencyWeight: tuple [
	"generic algorithm is to take all dependencies of the `tuple key` (row of the DSM) and count
	 those that can be scoped up to the `tuple value` (column of the DSM)"
	
	^(dependencyDictionary at: (tuple key model -> tuple value model ))
		size
]

{ #category : #initialization }
MiDependencyStructuralMatrixBrowserModel >> increment: dictionary key: key value: increment [

	| oldValue |
	oldValue := dictionary at: key ifAbsent: [ ^self ].

	dictionary at: key put: oldValue + increment
]

{ #category : #initialization }
MiDependencyStructuralMatrixBrowserModel >> initialize [ 
	super initialize.

	self initializeColors.
	self newGraph.
	selectedEntities := #()
]

{ #category : #initialization }
MiDependencyStructuralMatrixBrowserModel >> initializeColors [
	nodeColors := Dictionary new: 5.

	nodeColors at: #diagonalCell put: Color veryLightGray.

	nodeColors at: #scc put: Color lightRed.
	nodeColors at: #showSCC put: Color red.

	"very light gray for cell not in diagonal and not in dependency"
	nodeColors at: #defaultCell put: (Color r: 0.9 g: 0.9 b: 0.9).

	"a 'nice' blue for cells with dependency"
	nodeColors at: #dependency put: (Color colorFrom: '#659ef6').
]

{ #category : #buildGraph }
MiDependencyStructuralMatrixBrowserModel >> initializeDependencies [
	 | entities |
	dependencyDictionary := Dictionary new.
	entities := self entities.
	entities do: [ :sourceEntity | 
		entities do: [ :targetEntity | 
			dependencyDictionary
				at: (sourceEntity -> targetEntity)
				put: (self getDependenciesFrom: sourceEntity to: targetEntity) 
		]
	]
]

{ #category : #testing }
MiDependencyStructuralMatrixBrowserModel >> isCycle: tuple [

	^tuple key cycleNodes
		includes: tuple value
]

{ #category : #testing }
MiDependencyStructuralMatrixBrowserModel >> isDependency: tuple [

	^tuple key adjacentNodes
		includes: tuple value
]

{ #category : #testing }
MiDependencyStructuralMatrixBrowserModel >> isDiagonal: tuple [

	^tuple key = tuple value

]

{ #category : #accessing }
MiDependencyStructuralMatrixBrowserModel >> miSelectedItem [

	^selectedEntities
]

{ #category : #buildGraph }
MiDependencyStructuralMatrixBrowserModel >> newGraph [
	graph := AITarjan new.

	orderedNodesX := #().
	orderedNodesY := #()
]

{ #category : #actions }
MiDependencyStructuralMatrixBrowserModel >> openDetailedDSMOn: aTuple [
	"note: RSDSM calls X the columns (#value of aTuple) and Y the rows (#key of aTuple)"

	MiDependencyStructuralMatrixBrowser
		openWithX: aTuple value model children
		withY: aTuple key model children
]

{ #category : #initialization }
MiDependencyStructuralMatrixBrowserModel >> orderNodes [
	"Store ordered nodes in #orderedNodes.
	 Order is:
	 - number of combined in and out dependencies
	 - if equal, number of out dependencies
	 - if also equal, then name"
	
	orderedNodesX:= graph nodes.
	orderedNodesY := graph nodes.
	
	"| incomingEdges |
	incomingEdges := Dictionary new: graph nodes size.
	graph nodes do: [ :node | incomingEdges at: node put: Set new ].
	graph nodes do: [ :node |
		node adjacentNodes do: [ :adjacent |
			(incomingEdges at: adjacent) add: node
		].
	]."
	"orderedNodes := graph nodes sorted: [ :nodeA :nodeB || outA inA outB inB|
		outA := nodeA adjacentNodes size.
		inA := (incomingEdges at: nodeA) size.
		outB := nodeB adjacentNodes size.
		inB := (incomingEdges at: nodeB) size.
		
		(inA + outA) < (inB + outB)
		or: [ (inA + outA) = (inB + outB)
			ifTrue: [ outA < outB
				or: [ outA = outB and: [nodeA model name < nodeB model name] ] ]
			ifFalse: [ false ] ] ]."
]

{ #category : #initialization }
MiDependencyStructuralMatrixBrowserModel >> orderNodes: nodeCollection [

	"order nodes according to number of dependencies
	 Order is:
	 - first the less outgoing dependencies
	 - if equal, then first less incoming dependencies
	 - if equal, then alphabetical order"

	| inDependencies outDependencies |
	inDependencies := Dictionary new: nodeCollection size.
	outDependencies := Dictionary new: nodeCollection size.

	nodeCollection do: [ :node |
		inDependencies at: node model put: 0.
		outDependencies at: node model put: 0
	].

	dependencyDictionary keysAndValuesDo: [ :tuple :dependencies |
		dependencies ifNotEmpty: [
			self increment: inDependencies key: tuple value value: 1.
			self increment: outDependencies key: tuple key value: 1
		]
	].

	^nodeCollection sorted: [ :nodeA :nodeB || outA inA outB inB|
		outA := outDependencies at: nodeA model.
		inA :=  inDependencies  at: nodeA model.
		outB := outDependencies at: nodeB model.
		inB :=  inDependencies  at: nodeB model.
"1halt."
		(outA < outB)
		or: [ (outA = outB)
			ifTrue: [ (inA < inB)
				or: [ (inA = inB) and: [nodeA model name < nodeB model name] ] ]
			ifFalse: [ false ] ] 
	]

]

{ #category : #accessing }
MiDependencyStructuralMatrixBrowserModel >> orderedNodesX [
	^orderedNodesX
]

{ #category : #accessing }
MiDependencyStructuralMatrixBrowserModel >> orderedNodesY [
	^orderedNodesY
]

{ #category : #settings }
MiDependencyStructuralMatrixBrowserModel >> sccColor [

	^ nodeColors at: #scc
]

{ #category : #api }
MiDependencyStructuralMatrixBrowserModel >> sccTuplesForTuple: tuple [
	"gets the SCC owning tuple, then collects all tuples in this SCC
	 where row entity depends on column entity"
	| scc graphNode |
	graphNode := tuple key.
	scc := { graphNode } , graphNode cycleNodes.
	^(scc size = 1)
		ifTrue: [ #() ]
		ifFalse: [
			scc flatCollect: [ :rowNode |
				rowNode adjacentNodes
					collect: [ :columnNode | rowNode -> columnNode ]
					thenSelect: [ :sccTuple | self isCycle: sccTuple ]
			]
		]
]

{ #category : #accessing }
MiDependencyStructuralMatrixBrowserModel >> selectedEntities: anObject [

	selectedEntities := anObject.

	browser updateToolbar
]

{ #category : #settings }
MiDependencyStructuralMatrixBrowserModel >> settings [

]

{ #category : #settings }
MiDependencyStructuralMatrixBrowserModel >> showSCCColor [

	^ nodeColors at: #showSCC
]

{ #category : #api }
MiDependencyStructuralMatrixBrowserModel >> showSCCColorForTuple: tuple [
	"same as #colorForTuple: but highlighting SCCs"

	(self isDiagonal: tuple) ifTrue: [ ^self diagonalColor ].
	(self isDependency: tuple) ifFalse: [ ^self defaultColor ].

	(self isCycle: tuple) ifTrue: [ ^ self showSCCColor ].
	^ self dependencyColor
]

{ #category : #actions }
MiDependencyStructuralMatrixBrowserModel >> userActionOn: aTuple [


	self selectedEntities: { aTuple key model . aTuple value model }.
	self openDetailedDSMOn: aTuple

]

{ #category : #actions }
MiDependencyStructuralMatrixBrowserModel >> withX: entitiesX withY: entitiesY [

	| allEntities |
	allEntities := entitiesX union: entitiesY.

	self selectedEntities: allEntities.
	self buildGraph: allEntities.

	orderedNodesX := self orderNodes: (entitiesX collect: [ :each | graph findNode: each]).
	orderedNodesY := self orderNodes: (entitiesY collect: [ :each | graph findNode: each]).

	browser buildDSM
]
