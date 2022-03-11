Class {
	#name : #MiDMBrowserTest,
	#superclass : #MiAbstractBrowserTest,
	#category : #'MooseIDE-Tests-Browsers'
}

{ #category : #running }
MiDMBrowserTest >> browserClass [

	^ MiDMBrowser
]

{ #category : #tests }
MiDMBrowserTest >> testIsConsumerOfFQAbstractQuery [

	self assert:
		((browser application consumersOf: FQAbstractQuery) anySatisfy: [ 
			 :elt | elt = browser settings ])
]

{ #category : #tests }
MiDMBrowserTest >> testIsConsumerOfMiDynamicTag [

	self assert:
		((browser application consumersOf: MiDynamicTag) anySatisfy: [ 
			 :elt | elt = browser ])
]