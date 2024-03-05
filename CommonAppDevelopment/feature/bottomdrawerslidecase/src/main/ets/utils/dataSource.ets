@Observed
class SettingItem {
  public id: string; // 唯一id
  public image: Resource; // 图片

  constructor(id: string , image: Resource) {
    this.id = id;
    this.image = image;
  }
}

export { SettingItem };