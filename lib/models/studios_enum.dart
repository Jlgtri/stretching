// /// The enumeration of all studios of the SMStretching.
// enum SMStudio {
//   /// See: https://smstretching.ru/allstudios/studiya-na-chistih-prudah/
//   studiyaNaChistihPrudah,

//   /// See: https://smstretching.ru/allstudios/studiya-park-kultury/
//   studiyaParkKultury,

//   /// See: https://smstretching.ru/allstudios/chehovskaya/
//   chehovskaya,

//   /// See: https://smstretching.ru/allstudios/prospekt_mira/
//   prospektMira,

//   /// See: https://smstretching.ru/allstudios/studiya-na-tulskoy/
//   studiyaNaTulskoy,
// }

// /// All of the data of the studios of the SMStretching.
// extension SMStudioData on SMStudio {
//   /// Gets the studio from the [studioId] if any.
//   static SMStudio? byId(final int studioId) {
//     return (SMStudio.values.cast<SMStudio?>()).firstWhere(
//       (final studio) => studio!.id == studioId,
//       orElse: () => null,
//     );
//   }

//   /// The id of this studio in the YClients API.
//   int get id {
//     switch (this) {
//       case SMStudio.studiyaNaChistihPrudah:
//         return 193064;
//       case SMStudio.studiyaParkKultury:
//         return 455924;
//       case SMStudio.chehovskaya:
//         return 456372;
//       case SMStudio.prospektMira:
//         return 456379;
//       case SMStudio.studiyaNaTulskoy:
//         return 456384;
//     }
//   }

//   /// The id of the goods category of this studio in the YClients API.
//   int get categoryId {
//     switch (this) {
//       case SMStudio.studiyaNaChistihPrudah:
//         return 645274;
//       case SMStudio.studiyaParkKultury:
//         return 645275;
//       case SMStudio.chehovskaya:
//         return 645277;
//       case SMStudio.prospektMira:
//         return 645276;
//       case SMStudio.studiyaNaTulskoy:
//         return 651706;
//     }
//   }
// }
