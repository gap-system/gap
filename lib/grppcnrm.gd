InfoPcNormalizer := NewInfoClass( "InfoPcNormalizer" );


PcgsStabilizer := NewOperation(
    "PcgsStabilizer",
    [ IsPcgs, IsPcgs, IsPcgs ] );


NormalizerInHomePcgs := NewAttribute(
    "NormalizerInHomePcgs",
    IsGroup and HasHomePcgs );
