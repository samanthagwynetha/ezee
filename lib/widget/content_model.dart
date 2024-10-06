class UnboardingContent{
  String image;
  String title;
  String description;
  UnboardingContent({required this.description, required this.image, required this.title});
}

List<UnboardingContent> contents=[
  UnboardingContent(
    description: "Lorem ipsum dolor sit amet. Ut quis incidunt aut vero enim quo necessitatibus laudantium. Id ratione dicta ad culpa ipsum aut quos laboriosam eos voluptatem corporis. Non aperiam quam aut sunt mollitia ea eligendi debitis.", 
    image: "images/image2.jpg", 
    title: 'Pick any comfy room'),

  UnboardingContent(
    description: "Lorem ipsum dolor sit amet. Ut quis incidunt aut vero enim quo necessitatibus laudantium. Id ratione dicta ad culpa ipsum aut quos laboriosam eos voluptatem corporis. Non aperiam quam aut sunt mollitia ea eligendi debitis.", 
    image: "images/image2.jpg", 
    title: 'Pick any comfy room 1'),
];