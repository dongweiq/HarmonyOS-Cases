export class CardData {
  id: number;
  imageSrc: ResourceStr;
  title: string;
  content: string;
  authorName: string;
  avatorSrc: ResourceStr;
  cardArea: Area;

  constructor(id: number,
    imageSrc: ResourceStr,
    title: string,
    content: string,
    authorName: string,
    avatorSrc: ResourceStr
  ) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.title = title;
    this.content = content;
    this.authorName = authorName;
    this.avatorSrc = avatorSrc;
    this.cardArea = {
      width: 0,
      height: 0,
      position: {
        x: 0,
        y: 0,
      },
      globalPosition: {
        x:0,
        y:0
      }
    }
  }
}